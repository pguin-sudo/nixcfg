{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.suites.development;
in
{
  options.features.suites.development.enable = mkEnableOption "dev suite";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Python
      python3
      poetry
      # Moved to neovim config
      #basedpyright
      #ruff

      # Rust
      rustup

      # JS
      nodejs_24
      bun

      # C
      clang

      # Tools
      docker-compose
      openssl
      pgadmin4-desktopmode

      # AI
      aider-chat-full
      cursor-cli
    ];

    services.remmina = {
      enable = true;
      systemdService.enable = false;
    };

    programs.zed-editor = {
      enable = true;
    };
  };
}
