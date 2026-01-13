{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.vm;
in
{
  options.common.services.vm.enable = mkEnableOption "enable windows vm";

  config = mkIf cfg.enable {
    # Install necessary packages
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

    # Manage the virtualisation services
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          vhostUserPackages = with pkgs; [ virtiofsd ];
          swtpm.enable = true;
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}
