{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.themes.gtk;
in {
  options.features.themes.gtk.enable = mkEnableOption "gtk theme";

  config = mkIf cfg.enable {
    gtk = {
      enable = true;

      theme = {
        name = lib.mkForce "adw-gtk3-dark";
        package = lib.mkForce pkgs.adw-gtk3;
      };

      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = ''1'';
      };

      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = ''1'';
      };
    };
  };
}
