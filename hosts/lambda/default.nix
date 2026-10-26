{ pkgs, ... }:
{
  imports = [
    ../common
    ./hardware.nix
    ./disks.nix
  ];

  networking.hostName = "lambda";

  # Power/lid button handled by Hyprland (see home/lambda.nix), not logind directly.
  services.logind.settings.Login = {
    HandlePowerKey = "ignore";
    HandleLidSwitch = "ignore";
    HandleLidSwitchDocked = "ignore";
    HandleLidSwitchExternalPower = "ignore";
  };

  services.smkb.slave = {
    enable = true;
    user = "pguin";
  };

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.systemd-boot.configurationLimit = 3;
    kernelParams = [
      "processor.max_cstate=5"
      "idle=nomwait"
    ];
  };

  hardware.enableRedistributableFirmware = true;
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      rocmPackages.clr
      rocmPackages.clr.icd
    ];
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice
    adwaita-icon-theme
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        vhostUserPackages = [ pkgs.virtiofsd ];
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}
