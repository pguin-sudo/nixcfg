{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.kitty;
in {
  options.features.desktop.kitty.enable =
    mkEnableOption "install additional kitty for desktop apps";

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;

      settings = {
        bold_italic_font = "auto";

        window_padding_width = 14;
        window_padding_height = 14;
        hide_window_decorations = "yes";
        show_window_resize_notification = "no";
        confirm_os_window_close = 0;

        map = "F11 toggle_fullscreen";

        single_instance = "yes";
        allow_remote_control = "yes";

        cursor_shape = "block";
        enable_audio_bell = "no";

        tab_bar_edge = "bottom";
        tab_bar_style = "powerline";
        tab_powerline_style = "slanted";
        tab_title_template = "{title}{' :{}:'.format(num_windows) if num_windows > 1 else ''}";
      };
    };
  };
}
