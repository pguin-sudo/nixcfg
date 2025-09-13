{
  config,
  lib,
  ...
}:
with lib; {
  imports = [
    ../common
    ./home.nix
    ../features/cli
    ../features/desktop
  ];

  config = mkMerge [
    {
      xdg = {
        # TODO: better structure
        enable = true;
        configFile."mimeapps.list".force = true;
        mimeApps = {
          enable = true;
          associations.added = {
            "application/zip" = ["org.gnome.FileRoller.desktop"];
            "application/csv" = ["calc.desktop"];
            "application/pdf" = ["vivaldi-stable.desktop"];
            "x-scheme-handler/http" = ["vivaldi-stable.desktop"];
            "x-scheme-handler/https" = ["vivaldi-stable.desktop"];
          };
          defaultApplications = {
            "application/zip" = ["org.gnome.FileRoller.desktop"];
            "application/csv" = ["calc.desktop"];
            "application/pdf" = ["vivaldi-stable.desktop"];
            "application/md" = ["dev.zed.Zed.desktop"];
            "application/text" = ["dev.zed.Zed.desktop"];
            "x-scheme-handler/http" = ["vivaldi-stable.desktop"];
            "x-scheme-handler/https" = ["vivaldi-stable.desktop"];
          };
        };
      };

      features = {
        cli = {
	  neovim.enable = true;
          starship.enable = true;
        };
        desktop = {
          fonts.enable = true;
          gaming.enable = true;
          hyprland.enable = true;
          media.enable = true;
          office.enable = true;
          rofi.enable = true;
	  wayland.enable = true;
        };
      };
    }
  ];
}
