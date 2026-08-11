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
      # Nix
      nixd
      nil

      # Python
      (lib.hiPrio python313)
      python314
      poetry
      # Moved to neovim config
      #basedpyright
      #ruff
      python313Packages.pytest

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
      gnumake
      insomnia

      # AI
      claude-code

      # Gamedev
      godot_4

      # Devops
      ansible
      opentofu
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
