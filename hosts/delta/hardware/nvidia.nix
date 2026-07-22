{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.nvidia;
in {
  options.hardware.nvidia.enable = mkEnableOption "nvidia driver";

  config = mkIf cfg.enable {
    #Allow unfree packages
    nixpkgs.config.allowUnfree = true;

    services.xserver = {
      videoDrivers = ["nvidia"];
    };

    hardware = {
      graphics.enable = true;
      # opengl.driSupport = true;
      graphics.enable32Bit = true;
      graphics = {
        extraPackages = with pkgs; [
          libvdpau-va-gl
          libva-vdpau-driver
          mesa
        ];
      };

      nvidia.nvidiaSettings = true;
      # Desktop with a single discrete NVIDIA GPU (no iGPU) — no PRIME/offload,
      # finegrained power management is laptop-only (hybrid graphics).
      nvidia.powerManagement.enable = true;
      nvidia.open = false;

      # nvidia-drm.modeset=1 is required for some wayland compositors, e.g. sway
      nvidia.modesetting.enable = true;

      # GTX 1070 Ti (Pascal/GP104) is no longer supported by the "stable" branch
      # (595.x dropped Pascal) — the 580.x legacy branch is the last one that works.
      nvidia.package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
    };

    hardware.nvidia-container-toolkit.enable = true;

    environment.systemPackages = with pkgs; [
      cudatoolkit
    ];
  };
}
