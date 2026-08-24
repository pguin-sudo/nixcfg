{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.zapret;
in
{
  # nixpkgs now ships its own services.zapret2 module (added upstream after
  # our last flake update) which collides with zapret2-nix's module of the
  # same option path; disable the built-in one so zapret2-nix's preset-based
  # module (with its different option schema: presets/extraPresets/etc.) wins.
  disabledModules = [ "services/networking/zapret2.nix" ];

  options.common.services.zapret.enable = mkEnableOption "enable zapret";
  config = mkIf cfg.enable {
    services.zapret2 = {
      enable = true;
      presets = [
        "youtube"
        "discord"
        "general"
        "general-ts"
      ];
      firewall.ports.udp = [
        "443"
        "50000-65535"
      ];
      defaultPreset = "general-ts";
      extraPresets = {
        penis = {
          description = "Test preset";
          profiles = [
            {
              filter = {
                tcp = "443";
                l7 = [ "tls" ];
              };
              payload = [ "tls_client_hello" ];
              desync = [
                "fake:blob=fake_default_tls"
                "multisplit:pos=1"
              ];
            }
          ];
        };
      };
    };
    networking.nftables.enable = true;
  };
}
