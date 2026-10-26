{ pkgs, ... }:
{
  imports = [
    ../common
    ./hardware.nix
    ./hotspot.nix
    ./disks.nix
  ];

  networking.hostName = "delta";

  # Needed for OpenRGB to reach the motherboard's I2C/SMBus RGB controllers
  hardware.i2c.enable = true;
  boot.kernelModules = [ "i2c-piix4" ];

  # Power button handled by Hyprland (see home/desktop/hyprland.nix),
  # not logind directly.
  services.logind.settings.Login.HandlePowerKey = "ignore";

  # RGB off while suspended, back to the noctalia-derived color on resume
  # (see home/desktop/rgb.nix).
  powerManagement.powerDownCommands = ''
    ${pkgs.openrgb}/bin/openrgb -d 0 -z 0 -sz 12 -c 000000 -m static || true
  '';
  powerManagement.resumeCommands = ''
    color=$(tr -d '#\n' < /home/pguin/.config/noctalia/generated/rgb-color.conf 2>/dev/null)
    ${pkgs.openrgb}/bin/openrgb -d 0 -z 0 -sz 12 -c "''${color:-000000}" -m static || true
  '';

  services.udev = {
    # For plight
    extraRules = ''
      SUBSYSTEM=="tty", TAG+="uaccess", MODE="0666"
    '';
    packages = with pkgs; [
      openrgb
      vial
    ];
  };

  hardware.keyboard.qmk.enable = true;

  services.smkb.master = {
    enable = true;
    user = "pguin";
  };

  environment.systemPackages = with pkgs; [
    vial
    qmk
    ntfs3g
    lsof
    os-prober
  ];

  boot.loader = {
    systemd-boot.enable = false;
    grub = {
      enable = true;
      devices = [ "nodev" ];
      efiSupport = true;
      useOSProber = true;
      efiInstallAsRemovable = false;
      configurationLimit = 5;
      theme = null;
      splashImage = null;
    };
    efi = {
      canTouchEfiVariables = true;
      efiSysMountPoint = "/boot";
    };
  };
}
