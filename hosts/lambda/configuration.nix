{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Hardware
  hardware.battery.enable = false;
  hardware.asus-numpad.enable = false;

  # Common
  # System
  common.services.polkit.enable = false;
  common.services.xdgportal.enable = false;
  common.services.openssh.enable = true;
  programs.nix-ld.enable = true; # Non nixos binaries such as mason LSPs
  # VM
  common.services.vm.enable = false;
  # AppStores
  common.services.appimage.enable = true;
  common.services.steam.enable = true;
  # Enable kernel modules for obs-studio
  common.services.obs-studio.enable = true;
  # I2P
  common.services.i2p.enable = true;
  # Docker
  common.services.docker.enable = true;
  # Zapret
  common.services.zapret.enable = true;

  #services.samba.enable = true;

  # Bootloader
  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.configurationLimit = 3;
    kernelPackages = pkgs.linuxPackages_6_12;
    kernelParams = ["processor.max_cstate=5" "idle=nomwait"];
  };

  hardware.enableRedistributableFirmware = true;

  #Graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };

  #Network
  #Define your hostname
  networking.hostName = "lambda";
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

  # Enable DBus service that allows applications to query and manipulate storage
  services.udisks2.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    zsh
    nssmdns

    os-prober
  ];

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
