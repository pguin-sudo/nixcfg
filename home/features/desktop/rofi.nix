{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.desktop.rofi;
in {
  options.features.desktop.rofi.enable = mkEnableOption "enable rofi";

  config = mkIf cfg.enable {
    programs.rofi = with pkgs; {
      enable = true;
      package = rofi.override {
        plugins = [
          rofi-calc
          rofi-emoji
          rofi-file-browser
        ];
      };
      pass = {
        enable = true;
        package = rofi-pass-wayland;
      };
      terminal = "\${pkgs.kitty}/bin/kitty";
      font = "Fira Code";
      extraConfig = {
        show-icons = true;
        disable-history = false;
        modi = "drun,calc,emoji,filebrowser";
        kb-primary-paste = "Control+V,Shift+Insert";
        kb-secondary-paste = "Control+v,Insert";
      };
      theme = let
        inherit (config.colorScheme) palette;
      in
        builtins.toString (pkgs.writeText "rofi-universal-theme.rasi" ''
          * {
            /* Universal theme colors from nix-colors */
            background:  #${palette.base00};
            surface:     #${palette.base01};
            overlay:     #${palette.base02};
            muted:       #${palette.base03};
            subtle:      #${palette.base04};
            text:        #${palette.base05};
            bright-text: #${palette.base06};
            highlight:   #${palette.base07};
            accent1:     #${palette.base08};
            accent2:     #${palette.base09};
            accent3:     #${palette.base0A};
            accent4:     #${palette.base0B};
            accent5:     #${palette.base0C};
            accent6:     #${palette.base0D};
            accent7:     #${palette.base0E};
            accent8:     #${palette.base0F};

            /* Global properties */
            background-color: @background;
            text-color: @text;
            font: "Fira Code 12";
            border: 0;
            margin: 0;
            padding: 0;
            spacing: 0;
          }

          window {
            background-color: @background;
            border: 1px;
            border-color: @accent7;
            border-radius: 6px;
            width: 40%;
            padding: 16px;
          }

          inputbar {
            children: [ prompt, entry ];
            spacing: 12px;
            padding: 8px;
            border-radius: 4px;
            background-color: @surface;
          }

          prompt {
            text-color: @accent7;
            background-color: transparent;
          }

          entry {
            placeholder: "Search...";
            placeholder-color: @subtle;
            text-color: @text;
            background-color: transparent;
            cursor-color: @accent7;
          }

          message {
            background-color: @surface;
            border-radius: 4px;
            padding: 8px;
            margin: 8px 0;
          }

          textbox {
            text-color: @text;
            background-color: transparent;
          }

          listview {
            background-color: transparent;
            margin: 8px 0 0;
            lines: 10;
            columns: 1;
            fixed-height: true;
            scrollbar: false;
          }

          element {
            background-color: transparent;
            text-color: @text;
            padding: 8px;
            border-radius: 4px;
            spacing: 8px;
          }

          element normal.normal {
            background-color: transparent;
            text-color: @text;
          }

          element selected.normal {
            background-color: @accent7;
            text-color: @background;
          }

          element alternate.normal {
            background-color: transparent;
            text-color: @text;
          }

          element-icon {
            background-color: transparent;
            size: 24px;
          }

          element-text {
            background-color: transparent;
            text-color: inherit;
            vertical-align: 0.5;
          }

          mode-switcher {
            spacing: 0;
            background-color: @surface;
            border-radius: 4px;
            margin: 8px 0 0;
          }

          button {
            padding: 8px 16px;
            background-color: transparent;
            text-color: @text;
            border-radius: 4px;
          }

          button selected {
            background-color: @accent7;
            text-color: @background;
          }

          /* Scrollbar */
          scrollbar {
            width: 4px;
            border: 0;
            handle-color: @accent7;
            handle-width: 4px;
            padding: 0;
          }
        '');
    };
  };
}

