# Common configuration for all hosts
{
  config,
  lib,
  pkgs,
  inputs,
  outputs,
  ...
}:
{
  imports = [
    ./pguin.nix
    ./vpn.nix
    ./zapret.nix
    inputs.home-manager.nixosModules.home-manager
    inputs.noctalia-greeter.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit inputs outputs; };
    backupFileExtension = "backup";
  };

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];

  # nixos-manual-html fails to build: nixpkgs' redirects.json expects doc
  # anchors from the built-in services.zapret2 module, but we disable that
  # module (see ./zapret.nix) in favor of zapret2-nix's own module of the
  # same option path, so those anchors go missing. No local nixos-help/manual
  # as a result -- see docs.nixos.dev / search.nixos.org instead.
  documentation.nixos.enable = false;

  nixpkgs = {
    overlays = [ (final: _: import ../../pkgs { pkgs = final; }) ];
    config.allowUnfree = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "pguin"
      ]; # Set users that are allowed to use the flake command
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
    optimise.automatic = true;
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) inputs
    );
    nixPath = [ "/etc/nix/path" ];
  };

  # Keyring fix
  environment.variables = {
    XDG_RUNTIME_DIR = "/run/user/$UID";
  };

  # Extra locales (ru_RU needed for CP1251 legacy apps under Wine/Bottles)
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "en_US.UTF-8/UTF-8"
    "ru_RU.UTF-8/UTF-8"
  ];

  boot.extraModprobeConfig = ''
    options hid_apple fnmode=2
    options v4l2loopback devices=1 video_nr=1 card_label="OBS Virtual Camera" exclusive_caps=1
  '';
  boot.kernelModules = [ "v4l2loopback" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  programs.nix-ld = {
    enable = true; # Non nixos binaries such as mason LSPs
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
    ];
  };

  networking.networkmanager.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  time.timeZone = "Asia/Yekaterinburg";
  services.ntp.enable = true;

  services.printing.enable = false;
  services.libinput.enable = true;
  services.libinput.touchpad.tapping = true;
  services.udisks2.enable = true;
  services.upower.enable = true;

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    zsh
    nssmdns
    libsecret
    seahorse
  ];

  system.stateVersion = "24.05"; # Did you read the comment?

  # Login/greeter -- https://docs.noctalia.dev/v5/greeter/
  programs.noctalia-greeter.enable = true;
  services.displayManager.defaultSession = "hyprland";
  programs.hyprland.enable = true;
  # greetd (the login manager noctalia-greeter drives) picks this up
  # automatically for its PAM service.
  services.gnome.gnome-keyring.enable = true;

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  services.resolved.enable = lib.mkForce false;
  networking.resolvconf.useLocalResolver = true;
  services.dnscrypt-proxy = {
    enable = true;
    settings = {
      listen_addresses = [ "127.0.0.1:53" ];
      ipv6_servers = false;
      require_dnssec = true;
      sources.public-resolvers = {
        urls = [
          "https://raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md"
          "https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md"
        ];
        cache_file = "/var/cache/dnscrypt-proxy/public-resolvers.md";
        minisign_key = "RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3";
      };
    };
  };
  networking.nameservers = [
    "127.0.0.1"
    "8.8.8.8"
    "1.1.1.1"
  ];
  systemd.services.dnscrypt-proxy.after = [ "network-online.target" ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  services.i2pd = {
    enable = true;
    settings = {
      http.enabled = true;
      httpproxy.enabled = true;
      socksproxy.enabled = true;
      sam.enabled = true;
      i2cp = {
        enabled = true;
        address = "127.0.0.1";
        port = 7654;
      };
    };
  };

  # So v4l2loopback (OBS virtual camera) can be loaded without sudo/pkexec
  security.polkit.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "pguin" ];
    };
  };

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  networking.firewall = {
    enable = false;
    allowedUDPPorts = [
      24642
      27036
      5900
      2007
      65432
    ];
    allowedTCPPorts = [
      24643
      2007
      65432
    ];
    allowedUDPPortRanges = [
      {
        from = 27000;
        to = 27100;
      }
    ];
  };

  services.usbmuxd.enable = true;
}
