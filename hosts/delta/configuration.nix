{pkgs, ...}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./partitioning.nix
  ];

  # Hardware
  # Nvidia
  hardware.nvidia.enable = true;
  # Battery
  hardware.battery.enable = false;

  # Common
  # System
  common.services.polkit.enable = false;
  common.services.xdgportal.enable = false;
  common.services.openssh.enable = true;
  programs.nix-ld.enable = true; # Non nixos binaries such as mason LSPs
  # VM
  common.services.vm.enable = true;
  # AppStores
  common.services.appimage.enable = true;
  common.services.steam.enable = true;

  #services.samba.enable = true;

  #Bootloader
  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      devices = ["nodev"];
      efiSupport = true;
      useOSProber = true;

      efiInstallAsRemovable = false;

      configurationLimit = 5;
      theme = null;
      splashImage = null;
    };

    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot/efi";
    };
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  #Network
  #Define your hostname
  networking.hostName = "delta";
  # Enable networking
  networking.networkmanager.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  # Bluethooth
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;

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

  # Enable udev for openrgb
  services.udev = {
    # For plight
    extraRules = ''
      SUBSYSTEM=="tty", TAG+="uaccess", MODE="0666"
    '';
    packages = [pkgs.openrgb];
  };

  # I2PD sservice
  services.i2pd.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    vim
    git
    zsh
    nssmdns
    i2pd

    os-prober
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
