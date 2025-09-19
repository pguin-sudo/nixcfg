{ config, lib, pkgs, ... }:

{
  home.username = lib.mkDefault "pguin";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";

  programs.home-manager.enable = true;
  
  programs.git = {
    enable = true;
    userName = "PGuin";
    userEmail = "138515193+pguin-sudo@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "master";
      pull.rebase = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper = {
      enable = true;
    };
  };

  home.stateVersion = "24.05";
}
