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

  #programs.zed-editor.enable = true;

  programs.codex = {
    enable = true;

    mutableSettings = true;

    context = ''
      Отвечай на русском языке.

      Перед изменениями изучай существующий код, архитектуру и соглашения проекта.
      Соблюдай принятые в проекте подходы, стиль и структуру.
      Пиши поддерживаемый код. Ограничивай изменения рамками задачи.

      Руководствуйся принципами SOLID, KISS и DRY.
      Не вводи абстракции и универсальные решения без практической необходимости.
      Не усложняй код ради формального соблюдения принципов.

      Не добавляй комментарии, пересказывающие код.
      Комментируй только неочевидные решения и сложную логику,
      которую нельзя разумно упростить.
      Комментарии должны быть краткими, по существу,
      и содержать только ASCII-символы плюс символы русского языка.

      Не создавай коммиты.
    '';
  };
}
