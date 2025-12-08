{
  imports = [
    ../common
    ../features/cli
    ../features/desktop
    ../features/suites
    ../features/themes
    ./delta/home.nix
  ];

  programs.git = {
    enable = true;
    userName = "PGuin";
    userEmail = "138515193+pguin-sudo@users.noreply.github.com";
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
      reticulum.enable = true;
    };
    desktop = {
      firefox.enable = true;
      fonts.enable = true;
      hyprland.enable = true;
      wayland.enable = true;
      xdg.enable = true;
      kitty.enable = true;
      dolphin.enable = true;
    };
    suites = {
      development.enable = true;
      gaming.enable = true;
      multimedia.enable = true;
      pentest.enable = true;
      productivity.enable = true;
      studio.enable = true;
    };
    themes = {
      gtk.enable = true;
      qt.enable = false;
      stylix.enable = true;
      rgb.enable = true;
      plight.enable = true;
    };
  };
}
