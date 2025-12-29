{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.fonts;
in {
  options.features.desktop.fonts.enable =
    mkEnableOption "install additional fonts for desktop apps";

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
    ];

    fonts.fontconfig = {
      enable = true;
      defaultFonts = {
        serif = ["Libertinus Serif" "DejaVu Serif" "Noto Serif"];
        sansSerif = ["Inter" "DejaVu Sans" "Noto Sans"];
        monospace = ["FiraCode Nerd Font Mono" "JetBrains Mono" "DejaVu Sans Mono"];
        emoji = ["Noto Color Emoji" "Twitter Color Emoji"];
      };
    };
  };
}
