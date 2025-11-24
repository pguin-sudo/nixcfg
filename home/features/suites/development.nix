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
      bun
      clang
      python3
      poetry
      basedpyright
      ruff
      rustup
      nodePackages.npm
    ];
  };
}
