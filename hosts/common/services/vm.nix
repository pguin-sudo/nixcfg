{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.common.services.vm;
in {
  options.common.services.vm.enable = mkEnableOption "enable windows vm";

  config = mkIf cfg.enable {
    # Enable dconf (System Management Tool)
    programs.dconf.enable = true;

    # Install necessary packages
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      spice
      spice-gtk
      spice-protocol
      win-virtio
      win-spice
      adwaita-icon-theme
    ];

    # Manage the virtualisation services
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          vhostUserPackages = with pkgs; [virtiofsd];
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [pkgs.OVMFFull.fd];
        };
      };
      spiceUSBRedirection.enable = true;
    };
    services.spice-vdagentd.enable = true;
  };
}
