{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.kitty;
in {
  options.features.desktop.kitty.enable =
    mkEnableOption "enable Kitty as the preferred terminal + desktop integration";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      settings = {
        bold_italic_font = "auto";
        window_padding_width = 14;
        window_padding_height = 14;
        hide_window_decorations = "yes";

        confirm_os_window_close = 0;
        show_window_resize_notification = "no";
        cursor_shape = "block";
        enable_audio_bell = "no";

        single_instance = "yes";
        allow_remote_control = "yes";

        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      };
    };

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
