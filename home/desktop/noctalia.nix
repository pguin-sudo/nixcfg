{
  config,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    nwg-displays
    adw-gtk3
    libsForQt5.qt5ct
    qt6Packages.qt6ct
  ];

  xdg.dataFile."noctalia/plugins/pguin/vpn_switcher".source =
    ../resources/noctalia-plugins/vpn_switcher;

  xdg.configFile."cava/config".text = ''
    [color]
    theme = "noctalia"
  '';

  programs.noctalia = {
    enable = true;

    systemd = {
      enable = false;
    };

    settings = {
      theme = {
        mode = "dark";
        source = "builtin";
        wallpaper_scheme = "m3-rainbow";
        builtin = "Gruvbox";

        templates = {
          enable_builtin_templates = true;
          builtin_ids = [
            "btop"
            "cava"
            "gtk3"
            "gtk4"
            "hyprland"
            "kitty"
            "qt"
            "starship"
          ];

          enable_community_templates = true;
          community_ids = [
            "claude-code"
            "zen-browser"
            "discord"
            "telegram"
            "blender"
            "neovim"
            "obsidian"
            "zed"
            "prismlauncher"
            "fastfetch"
            "obs"
            "bat"
            "tmux"
            "yazi"
          ];

          user = {
            kitty = {
              enabled = true;
              input_path = "${config.programs.noctalia.package}/share/noctalia/assets/templates/kitty/kitty.conf";
              output_path = "~/.config/noctalia/generated/kitty-colors.conf";
              post_hook = "pkill -USR1 kitty || true";
            };
            neovim = {
              enabled = true;
              input_path = "${../resources/noctalia-templates/nvim-matugen.lua}";
              output_path = "~/.config/nvim/lua/matugen.lua";
              post_hook = "pkill -SIGUSR1 nvim || true";
            };
            tmux = {
              enabled = true;
              input_path = "${../resources/noctalia-templates/tmux-colors.conf}";
              output_path = "~/.config/tmux/noctalia-colors.conf";
              post_hook = ''tmux source-file "$HOME/.config/tmux/noctalia-colors.conf" >/dev/null 2>&1 || true'';
            };
          };
        };
      };

      audio.enable_sounds = false;

      calendar.enabled = true;

      wallpaper = {
        enabled = true;
        directory = "${config.home.homeDirectory}/Wallpapers";
        default.path = "${config.home.homeDirectory}/Wallpapers/gruvbox/forest.jpg";
      };

      plugins = {
        enabled = [
          "radimous/prismlauncher-instances"
          "pguin/vpn_switcher"
        ];
        source = [
          {
            kind = "git";
            location = "https://github.com/noctalia-dev/official-plugins";
            name = "official";
          }
          {
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
            name = "community";
          }
          {
            kind = "path";
            location = "~/.local/share/noctalia/plugins/pguin";
            name = "Local";
          }
        ];
      };

      lockscreen_widgets = {
        enabled = false;
        schema_version = 2;
      };

      bar.default = {
        position = "top";
        reserve_space = true;

        margin_edge = 0;
        margin_ends = 0;
        radius = 0;

        thickness = 36;
        padding = 8;
        widget_spacing = 8;
        background_opacity = 1.0;
        shadow = true;
        font_weight = 500;

        capsule = true;
        capsule_fill = "surface_variant";
        capsule_opacity = 0.8;
        capsule_border = "outline";

        center = [
          "privacy"
          "media"
          "clock"
          "widget"
        ];
        concave_edge_corners = true;
        end = [
          "tray"
          "group:g1"
          "group:g4"
          "group:g2"
          "group:g3"
        ];
        panel_overlap = 0;
        start = [
          "control-center"
          "workspaces"
        ];

        capsule_group = [
          {
            accordion = true;
            accordion_direction = "end";
            border = "outline";
            border_width = 1.0;
            enabled = true;
            fill = "surface_variant";
            id = "g1";
            members = [
              "volume"
              "bluetooth"
            ];
            opacity = 0.80000001192092896;
            padding = 6.0;
          }

          {
            accordion = true;
            accordion_direction = "end";
            border = "outline";
            border_width = 1.0;
            enabled = true;
            fill = "surface_variant";
            id = "g2";
            members = [
              "cpu"
              "temp"
              "Sep"
              "GPU"
              "TemperatureGPU"
              "Sep"
              "ram"
            ];
            opacity = 0.80000001192092896;
            padding = 11.0;
          }

          {
            accordion = true;
            accordion_direction = "start";
            border = "outline";
            border_width = 1.0;
            enabled = true;
            fill = "surface_variant";
            id = "g3";
            members = [
              "network"
              "network_tx"
              "network_rx"
            ];
            opacity = 0.80000001192092896;
            padding = 6.0;
          }

          {
            accordion = true;
            accordion_direction = "end";
            border = "outline";
            border_width = 1.0;
            enabled = true;
            fill = "surface_variant";
            id = "g4";
            members = [
              "battery"
              "brightness"
            ];
            opacity = 0.80000001192092896;
            padding = 6.0;
          }
        ];
      };

      widget.clock = {
        format = "{:%H:%M}";
        tooltip_format = "{:%A, %d %B %Y}";
      };

      widget.media = {
        hide_when_no_media = true;
        title_scroll = "on_hover";
        max_length = 220;
      };

      shell = {
        font_family = "FiraCode";
        panel.transparency_mode = "soft";
        screen_time_enabled = true;
        settings_show_advanced = false;
        polkit_agent = true;
        screenshot.annotate = true; # open editor on screenshot
      };
    };
  };
}
