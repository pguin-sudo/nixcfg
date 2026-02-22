{
  imports = [
    ../common
    ../features/cli
    ../features/desktop
    ../features/suites
    ../features/themes
    ./lambda/home.nix
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "PGuin";
      user.email = "138515193+pguin-sudo@users.noreply.github.com";
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  features = {
    cli = {
      btop.enable = true;
      fzf.enable = true;
      fastfetch.enable = true;
      neovim.enable = true;
      tmux.enable = true;
      zsh.enable = true;
    };
    desktop = {
      firefox.enable = true;
      fonts.enable = true;
      hyprland.enable = true;
      wayland.enable = true;
      waybar.enable = false;
      quickshell.enable = true;
      xdg.enable = true;
      spotify.enable = true;
      kitty.enable = true;
      dolphin.enable = true;
    };
    suites = {
      development.enable = true;
      gaming.enable = true;
      mesh.enable = true;
      multimedia.enable = true;
      pentest.enable = true;
      productivity.enable = true;
      studio.enable = false;
    };
    themes = {
      gtk.enable = true;
      qt.enable = true;
      stylix.enable = true;
    };
  };
}
