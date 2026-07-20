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
    lfs.enable = true;
    extraConfig = {
      pull.rebase = true;
    };
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
      starship.enable = true;
      tmux.enable = true;
      yazi.enable = true;
      zsh.enable = true;
    };
    desktop = {
      firefox.enable = true;
      fonts.enable = true;
      hyprland.enable = true;
      waybar.enable = false;
      wayland.enable = true;
      dms.enable = true;
      xdg.enable = true;
      kitty.enable = true;
      dolphin.enable = true;
      spotify.enable = true;
      zed.enable = true;
    };
    suites = {
      development.enable = true;
      gaming.enable = true;
      mesh.enable = true;
      multimedia.enable = true;
      pentest.enable = true;
      productivity.enable = true;
      studio.enable = true;
    };
    themes = {
      gtk.enable = false;
      qt.enable = false;
      stylix.enable = false;
      rgb.enable = true;
      plight.enable = true;
    };
  };
}
