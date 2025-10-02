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
      btop.enable = true;
      neofetch.enable = true;
      neovim.enable = true;
      zsh.enable = true;
    };
    desktop = {
      fonts.enable = true;
      sway.enable = true;
      wayland.enable = true;
      xdg.enable = true;
    };
    themes = {
      gtk.enable = true;
      qt.enable = true;
    };
  };
}
