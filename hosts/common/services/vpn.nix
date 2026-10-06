{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.common.services.vpn;

  ikev2RuntimeDir = "/run/ikev2";
  ikev2RuntimeSwanctlConf = "${ikev2RuntimeDir}/swanctl.conf";

  # ISRG Root X1 — корневой сертификат Let's Encrypt, которым подписан
  # сертификат сервера i.pguin.ru. Файл кладём в store и ссылаемся на
  # него напрямую из swanctl.conf.
  isrgRootX1 = pkgs.fetchurl {
    url = "https://letsencrypt.org/certs/isrgrootx1.pem";
    sha256 = "sha256-IrVXonBVszYGtlWfN3A5KNPkrXnxELQH0EmG4YQ1Q9E=";
  };
in
{
  options.common.services.vpn = {
    enable = mkEnableOption "AmneziaWG + sing-box + IKEv2 VPN stack driven by vpnctl";

    user = mkOption {
      type = types.str;
      default = "pguin";
      description = ''
        User allowed to start/stop `awg-quick@*.service` and `sing-box@*.service`
        via polkit without a password prompt. vpnctl (system or user session)
        relies on this to avoid sudo on every connect/disconnect.
      '';
    };

    ikev2.enable = mkEnableOption "IKEv2 VPN";

    ikev2.passwordFile = mkOption {
      type = types.path;
      # /run is tmpfs and nothing in this repo populates /run/secrets (no
      # sops-nix/agenix here) -- that path would never exist. A plain file
      # under /etc survives reboots and just needs to be created once,
      # out-of-band, same as this repo's other unmanaged secrets (e.g.
      # ~/.config/smkb/psk).
      default = "/etc/ikev2/password";

      description = ''
        File containing the complete IKEv2 configuration, created manually
        (e.g. `install -m 600 /dev/stdin /etc/ikev2/password`) -- NOT managed
        by Nix/home-manager.

        Format:

          server=vpn.example.com
          remote_id=vpn.example.com
          username=myusername
          password=mypassword

        The file must not be stored in the Nix store.
      '';
    };
  };

  config = mkIf cfg.enable {

    # -----------------------------------------------------------------------
    # AmneziaWG
    # -----------------------------------------------------------------------

    boot.extraModulePackages = [
      config.boot.kernelPackages.amneziawg
    ];

    environment.systemPackages = [
      pkgs.amneziawg-tools
      pkgs.sing-box
      pkgs.vpnctl
    ]
    ++ optionals cfg.ikev2.enable [
      # swanctl сам найдёт vici-сокет работающего charon, конфиг
      # передавать не нужно. aes/sha1/sha2/hmac/nonce, нужные для
      # proposals ниже, собраны в pkgs.strongswan по умолчанию --
      # оверрайд не нужен.
      pkgs.strongswan
    ];

    systemd.packages = [
      pkgs.amneziawg-tools
    ];

    systemd.services."awg-quick@".path = with pkgs; [
      coreutils
      iproute2
      iptables
      nftables
      openresolv
      procps
    ];

    # -----------------------------------------------------------------------
    # sing-box
    # -----------------------------------------------------------------------

    systemd.services."sing-box@" = {
      description = "sing-box VPN profile - %i";

      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /etc/sing-box/configs/%i.json";

        Restart = "on-failure";
        RestartSec = 2;

        User = "root";
      };
    };

    # -----------------------------------------------------------------------
    # VPN profile directories
    # -----------------------------------------------------------------------

    systemd.tmpfiles.rules = [
      "d /etc/amnezia/amneziawg 0750 ${cfg.user} root -"
      "d /etc/sing-box/configs 0750 ${cfg.user} root -"
    ]
    ++ optionals cfg.ikev2.enable [
      "d ${ikev2RuntimeDir} 0700 root root -"
    ];

    # -----------------------------------------------------------------------
    # IKEv2 / strongSwan (swanctl)
    # -----------------------------------------------------------------------

    services.strongswan-swanctl = mkIf cfg.ikev2.enable {
      enable = true;

      # Модуль добавит `include /run/ikev2/swanctl.conf` в /etc/swanctl/swanctl.conf,
      # который затем подхватывается ExecStartPost'ом `swanctl --load-all`.
      includes = [ ikev2RuntimeSwanctlConf ];
    };

    systemd.services.ikev2-config = mkIf cfg.ikev2.enable {
      description = "Generate IKEv2 swanctl runtime configuration";

      before = [ "strongswan-swanctl.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;

        ExecStart = pkgs.writeShellScript "generate-ikev2-config" ''
          set -euo pipefail

          SECRET_FILE="${cfg.ikev2.passwordFile}"
          RUNTIME_DIR="${ikev2RuntimeDir}"
          ISRG_ROOT="${isrgRootX1}"

          if [ ! -f "$SECRET_FILE" ]; then
            echo "IKEv2 secret file does not exist: $SECRET_FILE" >&2
            exit 1
          fi

          # shellcheck disable=SC1090
          source "$SECRET_FILE"

          : "''${server:?server is missing}"
          : "''${remote_id:?remote_id is missing}"
          : "''${username:?username is missing}"
          : "''${password:?password is missing}"

          install -d -m 0700 "$RUNTIME_DIR"

          cat > "${ikev2RuntimeSwanctlConf}" <<EOF
          # ISRG Root X1 кладём в store, путь известен на этапе сборки.
          # Этого достаточно, чтобы charon проверил цепочку Let's Encrypt.
          authorities {
            isrg-root-x1 {
              file = $ISRG_ROOT
            }
          }

          connections {
            ikev2 {
              version = 2
              remote_addrs = $server
              # Запрашиваем внутренний адрес у сервера -- без этого local_ts
              # по умолчанию ("dynamic") берёт адрес интерфейса машины, а не
              # выданный сервером, и child SA не поднимается.
              vips = 0.0.0.0, ::

              local {
                auth = eap-mschapv2
                eap_id = $username
              }

              remote {
                auth = pubkey
                id = $remote_id
              }

              children {
                ikev2 {
                  remote_ts = 0.0.0.0/0
                  # none, а не trap: иначе charon сам поднимет туннель на
                  # первом же исходящем пакете, в обход vpnctl и его модели
                  # "один активный профиль за раз" (как у awg-quick@/sing-box@).
                  # vpnctl дергает ikev2-connection.service явно.
                  start_action = none
                  esp_proposals = aes256-sha256
                }
              }

              proposals = aes256-sha256-modp2048
              fragmentation = yes
              encap = yes
            }
          }

          secrets {
            eap-$username {
              id = $username
              secret = "$password"
            }
          }
          EOF

          chmod 600 "${ikev2RuntimeSwanctlConf}"
        '';
      };
    };

    # charon/swanctl run as root and own the vici socket -- rather than
    # exposing that socket to cfg.user, give vpnctl the same unit-based
    # start/stop contract it already uses for awg-quick@/sing-box@:
    # `systemctl start` initiates the SA (blocking until it's up or fails)
    # and leaves the unit "active" via RemainAfterExit, `systemctl stop`
    # runs ExecStop to terminate it. unitctl.is_active() then just works.
    systemd.services.ikev2-connection = mkIf cfg.ikev2.enable {
      description = "IKEv2 VPN connection (swanctl)";

      after = [
        "strongswan-swanctl.service"
        "network-online.target"
      ];
      wants = [ "network-online.target" ];
      requisite = [ "strongswan-swanctl.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        TimeoutStartSec = "30s";

        ExecStart = "${pkgs.strongswan}/sbin/swanctl --initiate --child ikev2";
        ExecStop = "${pkgs.strongswan}/sbin/swanctl --terminate --ike ikev2";
      };
    };

    # -----------------------------------------------------------------------
    # Polkit
    # -----------------------------------------------------------------------

    security.polkit.enable = true;

    environment.etc."polkit-1/rules.d/50-vpnctl.rules".text = ''
      polkit.addRule(function(action, subject) {
        if (action.id != "org.freedesktop.systemd1.manage-units") {
          return polkit.Result.NOT_HANDLED;
        }

        if (subject.user != "${cfg.user}") {
          return polkit.Result.NOT_HANDLED;
        }

        var unit = action.lookup("unit");

        if (
          unit &&
          (
            /^awg-quick@[^\/]+\.service$/.test(unit) ||
            /^sing-box@[^\/]+\.service$/.test(unit) ||
            unit == "ikev2-connection.service"
          )
        ) {
          return polkit.Result.YES;
        }

        return polkit.Result.NOT_HANDLED;
      });
    '';
  };
}
