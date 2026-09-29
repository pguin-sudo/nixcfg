{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.fonts;
in
{
  options.features.desktop.fonts.enable = mkEnableOption "install additional fonts for desktop apps";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inter
      libertinus
      jetbrains-mono
      fira-code
      cascadia-code

      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      nerd-fonts.hack
      nerd-fonts.mononoki

      noto-fonts-color-emoji
      twitter-color-emoji

      noto-fonts
      dejavu_fonts
      liberation_ttf

      corefonts # ms fonts (Times New Roman, Arial, Courier New, ...)
      vista-fonts # ms office fonts (Calibri, Cambria, Consolas, ...)
    ];

    # OnlyOffice can't handle font files that are (or are reached through)
    # symlinks -- https://github.com/ONLYOFFICE/DocumentServer/issues/1859 --
    # so no matter how these fonts are exposed via the Nix store
    # (fontconfig, its FHS sandbox's targetPkgs, a runtime bind-mount), it
    # never sees them, since every one of those paths ends in a symlink.
    # Copy the real bytes into ~/.local/share/fonts instead, which is the
    # one thing confirmed to work: https://github.com/NixOS/nixpkgs/issues/373521
    home.activation.onlyofficeFontsCopy = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run rm -rf "$HOME/.local/share/fonts"
      run mkdir -p "$HOME/.local/share/fonts"
      run cp -f ${pkgs.corefonts}/share/fonts/truetype/*.ttf ${pkgs.vista-fonts}/share/fonts/truetype/*.ttf ${pkgs.liberation_ttf}/share/fonts/truetype/*.ttf "$HOME/.local/share/fonts/"
      run chmod 755 "$HOME/.local/share/fonts"
      run chmod 644 "$HOME/.local/share/fonts"/*
    '';

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = [
          "Libertinus Serif"
          "DejaVu Serif"
          "Noto Serif"
        ];
        sansSerif = [
          "Inter"
          "DejaVu Sans"
          "Noto Sans"
        ];
        monospace = [
          "FiraCode Nerd Font Mono"
          "JetBrains Mono"
          "DejaVu Sans Mono"
        ];
        emoji = [
          "Noto Color Emoji"
          "Twitter Color Emoji"
        ];
      };
    };
  };
}
