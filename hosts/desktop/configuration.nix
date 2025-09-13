{ config, lib, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";  
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Yekaterinburg";

  nix.settings.trusted-users = [ "root" "pguin" ];	


  # === Services === 
  
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  services.openssh.enable = true;


  # === Packages === 

  environment.systemPackages = with pkgs; [
    neovim 
    wget
    git
    tree
    tmux
    dolphin
  ];

 
  # === Programs === 
 
  programs.firefox.enable = true;

  programs.zsh.enable = true;
 
  programs.hyprland.enable = true;
  
  system.stateVersion = "25.05"; 
}

