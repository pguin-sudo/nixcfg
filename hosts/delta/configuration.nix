{ pkgs, inputs, ... }: {

  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
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
  common.services.update-report.enable = true;
  programs.nix-ld.enable = true; # Non nixos binaries such as mason LSPs
  # Filemanager
  common.services.nautilus.enable = false;
  # Virtual Box (Virt-Manager) and GPU Passthru. you have to configure hosts/services/vfio.nix for passthrough to work!
  common.services.vm.enable = true;
  #common.services.vfio.enable = false;
  # AppStores
  common.services.appimage.enable = true;
  common.services.steam.enable = true;
  services.flatpak.enable = false;

  # Gnomede exclude these packages
  services.xserver = {
    desktopManager.gnome = {
      enable = true;
      extraGSettingsOverridePackages = [ pkgs.mutter ];
      extraGSettingsOverrides = ''
        [org.gnome.mutter]
        experimental-features=['scale-monitor-framebuffer']
      '';
    };
  };
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };
  environment.gnome.excludePackages = with pkgs; [
    cheese # photo booth
    epiphany # web browser
    simple-scan # document scanner
    totem # video player
    yelp # help viewer
    geary # email client

    # these should be self explanatory
    gnome-contacts
    gnome-music
    gnome-photos
  ];


  #services.samba.enable = true;


  #Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #Boot entries limit
  boot.loader.systemd-boot.configurationLimit = 3;
  # Ntfs support
  boot.supportedFilesystems = [ "ntfs" ];


  # Enable GDM Login Manager
  services.xserver.enable = true;
  services.xserver.displayManager.gdm = {
    enable = true;
    wayland = true;
    banner = "Nomadic Nixos";
    autoSuspend = true;
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
  #Hosts 
  networking.extraHosts = ''
    192.168.0.200 rancher.local
  '';

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

  # Keyboard
  services.xserver = {
    exportConfiguration = true; # link /usr/share/X11/ properly
    xkb.layout = "us,ara";
    xkb.options = "grp:alt_shift_toggle,ctrl:swapcaps";
    xkb.variant = "intl,";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;
  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true; #tap


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
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
