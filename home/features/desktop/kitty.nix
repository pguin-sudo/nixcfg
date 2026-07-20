{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.kitty;
in {
  options.features.desktop.kitty.enable =
    mkEnableOption "enable Kitty as the preferred terminal + desktop integration";

  config = mkIf cfg.enable {
    home.packages = [ pkgs.kitty ];

    home.file.".config/kitty/kitty.conf".text = ''
      include dank-tabs.conf
      include dank-theme.conf

      # Basic
      scrollback_lines 5000

      # UX
      confirm_os_window_close 0
      enable_audio_bell no

      # Style
      cursor_trail 500
      font_size 10.0
      window_padding_width 25
      background_opacity 0.3
      hide_window_decorations yes

      # Fonts
      font_family CaskaydiaCove Nerd Font Mono
      bold_font auto
      italic_font auto
      bold_italic_font auto
    '';

    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = ["kitty.desktop"];

        wayland = ["kitty.desktop"];
      };
    };

    home.file.".config/kdeglobals".text = ''
      [General]
      TerminalApplication=kitty
      TerminalService=kitty.desktop
    '';

    home.sessionVariables = {
      TERMINAL = "kitty";
    };
  };
}
