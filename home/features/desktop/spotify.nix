{
  config,
  lib,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.spotify;
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  options.features.desktop.spotify.enable = mkEnableOption "spotify";

  config = mkIf cfg.enable {
    programs.spicetify = {
      enable = true;

      enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.system}.extensions; [
        adblock
        hidePodcasts
        shuffle
      ];

      enabledCustomApps = with inputs.spicetify-nix.legacyPackages.${pkgs.system}.apps; [
        newReleases
      ];
    };

    # home.packages = [ pkgs.spotify ];
  };
}
