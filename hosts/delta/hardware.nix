{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.kernelModules = [ "kvm-amd" ];

  # fileSystems and swapDevices for the main disk are managed by disko (./disks.nix)
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    graphics.enable = true;
    graphics.enable32Bit = true;
    graphics.extraPackages = with pkgs; [
      libvdpau-va-gl
      libva-vdpau-driver
      mesa
      # VA-API over NVDEC, selected via LIBVA_DRIVER_NAME=nvidia (home/delta.nix)
      nvidia-vaapi-driver
    ];

    nvidia.nvidiaSettings = true;
    # Desktop with a single discrete NVIDIA GPU (no iGPU) -- no PRIME/offload,
    # finegrained power management is laptop-only (hybrid graphics).
    nvidia.powerManagement.enable = true;
    nvidia.open = false;
    nvidia.modesetting.enable = true;

    # GTX 1070 Ti (Pascal/GP104) is no longer supported by the "stable"
    # branch (595.x dropped Pascal) -- 580.x legacy is the last one that works.
    nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;

    nvidia-container-toolkit.enable = true;
  };

  environment.systemPackages = [ pkgs.cudatoolkit ];
}
