{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.common.services.vpn;
in
{
  options.common.services.vpn = {
    enable = mkEnableOption "AmneziaWG + sing-box VPN stack driven by vpnctl";

    user = mkOption {
      type = types.str;
      default = "pguin";
      description = ''
        User allowed to start/stop `awg-quick@*.service` and `sing-box@*.service`
        via polkit without a password prompt. vpnctl (system or user session)
        relies on this to avoid sudo on every connect/disconnect.
      '';
    };
  };

  # AmneziaVPN's own GUI client is untouched by this module -- it stays a
  # separate app used only to administer the server / export .conf profiles.
  # This module only wires up unattended local consumption of those exported
  # configs (AmneziaWG) and of Remnawave subscriptions (sing-box). Note that
  # the in-kernel module enabled below also accelerates AmneziaVPN's own
  # connections, since its bundled service falls back to the same
  # `/sys/module/amneziawg` check as awg-quick.
  config = mkIf cfg.enable {
    # `ip link add type amneziawg` needs the out-of-tree amneziawg kernel
    # module. This used to fail to build on this kernel (7.1.4 removed the
    # `ipv6_stub` symbol layout it relied on), forcing a silent fallback to
    # the much slower `amneziawg-go` userspace implementation for every
    # connection (roughly half the throughput, ~3x the latency -- confirmed
    # 2026-08-24). nixpkgs' amneziawg module has since been updated for
    # newer kernels, so build the real kernel module for whatever kernel
    # this host runs and load it -- `ip link add type amneziawg` then uses
    # it automatically via modalias, no further wiring needed. Keep
    # amneziawg-go installed regardless, as a fallback for the next time a
    # kernel bump outpaces the module.
    boot.extraModulePackages = [ config.boot.kernelPackages.amneziawg ];

    environment.systemPackages = [
      pkgs.amneziawg-tools
      pkgs.amneziawg-go
      pkgs.sing-box
      pkgs.vpnctl
    ];

    # amneziawg-tools ships its own templated awg-quick@.service (built with
    # WITH_SYSTEMDUNITS=yes) which runs `awg-quick up %i`; a bare instance
    # name resolves against /etc/amnezia/amneziawg/%i.conf by awg-quick's own
    # convention. systemd.packages just makes that unit file visible --
    # nothing autostarts since no [Install] target is pulled in anywhere.
    systemd.packages = [ pkgs.amneziawg-tools ];

    # The shipped unit sets no PATH, and awg-quick (a bash script) shells out
    # to readlink/ip/iptables/nft/sysctl/resolvconf -- none of which resolve
    # in systemd's default minimal PATH on NixOS. Declaring `path` here adds
    # a drop-in for the package-provided "awg-quick@" unit rather than
    # replacing it.
    systemd.services."awg-quick@".path = with pkgs; [
      coreutils
      iproute2
      iptables
      nftables
      openresolv
      procps
      amneziawg-go
    ];

    # No stock NixOS/nixpkgs unit for a per-profile sing-box instance exists
    # (services.sing-box in nixpkgs is a single non-templated, non-root
    # service meant for server-side use) -- so this is hand-written.
    systemd.services."sing-box@" = {
      description = "sing-box VPN profile - %i";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /etc/sing-box/configs/%i.json";
        Restart = "on-failure";
        RestartSec = 2;
        # The tun inbound needs CAP_NET_ADMIN; running as root keeps this
        # simple rather than threading AmbientCapabilities through.
        User = "root";
      };
    };

    # Owned by cfg.user, not root: `vpnctl add-source` (invoked from the
    # Noctalia panel, unprivileged) writes new profile configs here directly.
    # awg-quick@/sing-box@ still read them fine since both units run as root.
    systemd.tmpfiles.rules = [
      "d /etc/amnezia/amneziawg 0750 ${cfg.user} root -"
      "d /etc/sing-box/configs 0750 ${cfg.user} root -"
    ];

    security.polkit.enable = true;

    # Scoped to exactly the two unit-name patterns vpnctl drives -- no other
    # unit, and no other user, gets start/stop/restart rights from this rule.
    environment.etc."polkit-1/rules.d/50-vpnctl.rules".text = ''
      polkit.addRule(function(action, subject) {
        if (action.id != "org.freedesktop.systemd1.manage-units") {
          return polkit.Result.NOT_HANDLED;
        }
        if (subject.user != "${cfg.user}") {
          return polkit.Result.NOT_HANDLED;
        }
        var unit = action.lookup("unit");
        if (unit && (/^awg-quick@[^\/]+\.service$/.test(unit) || /^sing-box@[^\/]+\.service$/.test(unit))) {
          return polkit.Result.YES;
        }
        return polkit.Result.NOT_HANDLED;
      });
    '';
  };
}
