{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.common.services.docker;
in {
  options.common.services.docker.enable = mkEnableOption "enable docker";

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      rootless = {
        # Change all for true if wanna rootless
        enable = false;
        setSocketVariable = false;
      };
      extraOptions = ''--data-root=/home/pguin/docker-data'';
    };
  };
}
