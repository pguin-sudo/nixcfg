{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.suites.development;
in {
  options.features.suites.development.enable = mkEnableOption "dev suite";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Dev
      docker-compose

      clang

      bun
      basedpyright
      ruff

      python3
      rustup

      poetry
      nodePackages.npm

      openssl

      pgadmin4-desktopmode
    ];
  };
}
