{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  cfg = config.common.services.howdy;
  inherit (pkgs.stdenv.hostPlatform) system;
in {
  options.common.services.howdy.enable = lib.mkEnableOption "enable Howdy facial recognition authentication";

  config = lib.mkIf cfg.enable {
    services = {
      howdy = {
        enable = true;
        package = inputs.nixpkgs-howdy.legacyPackages.${system}.howdy;
        settings = {
          core = {
            no_confirmation = true;
            abort_if_ssh = true;
          };
          video = {
            device_path = "/dev/v4l/by-path/pci-0000:63:00.4-usb-0:1:1.2-video-index0";
            dark_threshold = 90;
          };
        };
      };

      linux-enable-ir-emitter = {
        enable = true;
        package = inputs.nixpkgs-howdy.legacyPackages.${system}.linux-enable-ir-emitter;
      };
    };
  };
}
