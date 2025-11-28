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
      # Python
      python3
      poetry
      basedpyright
      ruff

      # Rust
      rustup

      # JS
      nodePackages.npm
      bun

      # C
      clang

      # Tools
      docker-compose
      openssl
      pgadmin4-desktopmode

      # AI
      aider-chat-full
    ];
  };
}
