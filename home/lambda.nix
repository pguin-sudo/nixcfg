{ pkgs, ... }:
{
  imports = [ ./common.nix ];

  home.packages = [ pkgs.nvtopPackages.amd ];
  home.sessionVariables.LIBVA_DRIVER_NAME = "radeonsi";

  xdg.configFile."vpnctl/profiles.toml".source =
    (pkgs.formats.toml { }).generate "vpnctl-profiles.toml" {
      profile = [
        {
          name = "ikev2";
          type = "ikev2";
          unit = "ikev2-connection.service";
          config_path = "/run/ikev2/swanctl.conf";
        }
      ];
    };
}
