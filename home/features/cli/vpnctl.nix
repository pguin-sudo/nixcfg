{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.cli.vpnctl;

  tomlFormat = pkgs.formats.toml { };

  mkProfileEntry =
    p:
    {
      inherit (p) name type unit;
      config_path = p.configPath;
    }
    // optionalAttrs (p.interface != null) { inherit (p) interface; }
    // optionalAttrs (p.subscriptionUrl != null) { subscription_url = p.subscriptionUrl; }
    // optionalAttrs (p.subscriptionSelector != null) { subscription_selector = p.subscriptionSelector; }
    // optionalAttrs (p.type == "singbox") { subscription_source = "remnawave"; };

  profileSubmodule = types.submodule {
    options = {
      name = mkOption {
        type = types.str;
        description = "Unique profile name, as used by `vpnctl connect <name>`.";
      };
      type = mkOption {
        type = types.enum [
          "amnezia"
          "singbox"
        ];
        description = "amnezia = awg-quick@ unit over a manually-exported .conf; singbox = sing-box@ unit over a vpnctl-generated config.";
      };
      unit = mkOption {
        type = types.str;
        example = "awg-quick@home.service";
        description = "systemd unit vpnctl starts/stops for this profile.";
      };
      configPath = mkOption {
        type = types.str;
        description = "Path to the profile's config file (.conf for amnezia, .json for singbox).";
      };
      interface = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Network interface name for `vpnctl status` link/route checks. Defaults to the profile name (amnezia) or sing-tun0 (singbox) when unset.";
      };
      subscriptionUrl = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Per-profile override of [remnawave].url, for singbox profiles pulling from a different subscription.";
      };
      subscriptionSelector = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Case-insensitive substring matched against subscription server names to pick which endpoint this singbox profile syncs to. Unset = first usable endpoint.";
      };
    };
  };
in
{
  options.features.cli.vpnctl = {
    enable = mkEnableOption "vpnctl (unified AmneziaWG + sing-box/Remnawave VPN control)";

    remnawave = {
      url = mkOption {
        type = types.str;
        default = "https://magicvpnproxy.xyz/sub/xJZwgqs0jxPwpyoA";
        description = "Default Remnawave/VLESS subscription URL used by `vpnctl sync-singbox` for profiles without their own subscriptionUrl.";
      };
      hwid = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "x-hwid header sent with the subscription request, for panels enforcing a device limit.";
      };
    };

    profiles = mkOption {
      type = types.listOf profileSubmodule;
      default = [ ];
      description = "VPN profiles known to vpnctl. AmneziaWG profiles still require manually exporting the .conf from the AmneziaVPN GUI first -- vpnctl only consumes it.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.vpnctl ];

    xdg.configFile."vpnctl/profiles.toml".source = tomlFormat.generate "vpnctl-profiles.toml" {
      remnawave = {
        inherit (cfg.remnawave) url;
      }
      // optionalAttrs (cfg.remnawave.hwid != null) { inherit (cfg.remnawave) hwid; };
      profile = map mkProfileEntry cfg.profiles;
    };
  };
}
