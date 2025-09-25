{
  imports = [
    ../common
    ./dotfiles
    ../features/cli
    ../features/desktop
    ../features/themes
    ./nu/home.nix
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
      zsh.enable = true;
      neofetch.enable = true;
    };
    desktop = {
      fonts.enable = true;
      hyprland.enable = true;
      wayland.enable = true;
      xdg.enable = false;
    };
    themes = {
      gtk.enable = true;
      qt.enable = true;
    };
  };

}

