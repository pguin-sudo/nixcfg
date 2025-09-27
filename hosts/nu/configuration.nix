{ pkgs, inputs, ... }: {

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Hardware
  # Nvidia
  hardware.nvidia.enable = false;
  # Battery
  hardware.battery.enable = false;

  # Common
  # System
  common.services.polkit.enable = false;
  common.services.xdgportal.enable = false;
  programs.nix-ld.enable = true; # Non nixos binaries such as mason LSPs
  # Filemanager
  common.services.nautilus.enable = true;
  # Virtual Box (Virt-Manager) and GPU Passthru. you have to configure hosts/services/vfio.nix for passthrough to work!
  #common.services.vfio.enable = false;
  # AppStores
  common.services.appimage.enable = false;
  common.services.steam.enable = false;

  #services.samba.enable = true;

  #Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #Boot entries limit
  boot.loader.systemd-boot.configurationLimit = 3;
  # Ntfs support
  boot.supportedFilesystems = [ "ntfs" ];

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  #Network
  #Define your hostname
  networking.hostName = "nu";
  # Enable networking
  networking.networkmanager.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Bluethooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };


  # Set your time zone.
  time.timeZone = "Asia/Yekaterinburg";
  services.ntp = {
    enable = true;
  };

  # Enable CUPS to print documents.
  services.printing.enable = false;
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true; #tap


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  environment.systemPackages = with pkgs; [
    neovim
    git
    zsh
    nssmdns
  ];

  #Firewall
  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # For Chromecast from chrome
  # networking.firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
  networking.nftables.enable = false;


  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
