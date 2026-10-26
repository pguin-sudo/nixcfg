{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    # Nix
    nixd
    nil

    # Python
    (lib.hiPrio python313)
    python314
    poetry
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

    # IoT
    usbutils
  ];

  services.remmina = {
    enable = true;
    systemdService.enable = false;
  };

  programs.zed-editor.enable = true;
}
