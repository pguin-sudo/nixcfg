{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
with lib;
let
  cfg = config.features.desktop.noctalia;
in
{
  options.features.desktop.noctalia.enable = mkEnableOption "noctalia shell";

  # https://docs.noctalia.dev/v5/getting-started/nixos/
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      cava
      nwg-displays
      # Needed for GTK/Qt to actually pick up the generated color files
      adw-gtk3
      libsForQt5.qt5ct
      qt6Packages.qt6ct
    ];

    # Local plugin source: Noctalia auto-discovers plugins placed by hand
    # under ~/.local/share/noctalia/plugins/<author>/<plugin>/ (matching the
    # "<author>/<plugin>" id in plugin.toml) -- no separate registry file to
    # manage. Bar widgets reference it as "<author>/<plugin>:<widget id>".
    # See home/resources/noctalia-plugins/vpn_switcher for the plugin itself
    # and home/features/cli/vpnctl.nix for the CLI it drives.
    xdg.dataFile."noctalia/plugins/pguin/vpn_switcher".source =
      ../../resources/noctalia-plugins/vpn_switcher;

    # Minimal cava config so the `cava` builtin template has a file to target
    # (its apply.sh errors out if ~/.config/cava/config is missing). The
    # [color] theme line is pre-set to "noctalia" so apply.sh finds it already
    # there and never has to edit this (read-only) file; the template writes the
    # palette to ~/.config/cava/themes/noctalia.
    xdg.configFile."cava/config".text = ''
      [color]
      theme = "noctalia"
    '';

    programs.noctalia = {
      enable = true;

      systemd = {
        enable = false;
      };

      # Schema: https://github.com/noctalia-dev/noctalia/blob/main/example.toml
      # Validated at build time against `noctalia config validate` (validateConfig, default true).
      #
      # Template strategy (see noctalia-dev/noctalia-shell#2468):
      # Noctalia applies builtin, community and user templates in INDEPENDENT
      # passes — a user template does NOT override a builtin/community one of the
      # same id. So a template is safe to enable via builtin_ids/community_ids
      # only when everything it writes lands in a NON-managed file. When its
      # post_hook rewrites a home-manager-managed (read-only) file it fails
      # silently at runtime (~/.cache/noctalia/noctalia.log), so we instead drop
      # it from the id list and redeclare it under `user` with a safe output
      # path + a reload-only post_hook, then reference the generated file from
      # the app's HM config.
      settings = {
        theme = {
          mode = "dark";
          # Generate the palette from the current wallpaper via Matugen
          source = "wallpaper";
          # Matugen scheme variant (set from the shell's theme picker).
          wallpaper_scheme = "m3-rainbow";

          templates = {
            enable_builtin_templates = true;
            # Builtin templates whose apply.sh either writes a standalone colour
            # file with no managed-file conflict, or only edits the app's main
            # config when a selector line is missing — and we pre-seed that line
            # from Nix so the edit no-ops:
            #   gtk3/gtk4 -> ~/.config/gtk-*/noctalia.css  (@import handled;
            #                apply.sh converts a read-only gtk.css symlink itself)
            #   qt        -> ~/.config/qt*ct/colors/noctalia.conf  (no post_hook)
            #   btop      -> ~/.config/btop/themes/noctalia.theme
            #                (btop.nix sets color_theme = "noctalia")
            #   cava      -> ~/.config/cava/themes/noctalia
            #                (cava config below carries [color] theme = "noctalia")
            #   hyprland  -> ~/.config/hypr/noctalia.conf
            #                (hyprland.nix `source`s it; stub created on activation)
            # kitty/starship stay OUT of this list — their apply.sh rewrites a
            # read-only managed file with no idempotent escape; they are handled
            # as `user` templates instead (kitty here, starship in starship.nix).
            builtin_ids = [
              "btop"
              "cava"
              "gtk3"
              "gtk4"
              "hyprland"
              "qt"
            ];

            # Community templates. Fetched from api.noctalia.dev and cached under
            # ~/.local/state/noctalia/community-templates/ on first enable, so
            # they only theme once cached (not pure-reproducible, but no
            # managed-file conflict). Every output below lands in a NON-managed
            # location or only touches app state we don't manage:
            #   zed          -> ~/.config/zed/themes/noctalia.json       (no hook)
            #   yazi         -> ~/.config/yazi/flavors/noctalia.yazi/    (hook edits
            #                   the NON-managed ~/.config/yazi/theme.toml)
            #   bat          -> ~/.config/bat/themes/noctalia.tmTheme    (hook runs
            #                   `bat cache --build`; default.nix sets
            #                   programs.bat.config.theme = "noctalia")
            #   claude-code  -> ~/.claude/themes/noctalia.json           (no hook)
            #   discord      -> ~/.config/<client>/themes/noctalia*.css  (no hook;
            #                   needs a client mod, harmless otherwise)
            #   telegram     -> ~/.config/telegram-desktop/themes/       (no hook)
            #   obs          -> ~/.config/obs-studio/themes/matugen.obt   (no hook)
            #   obsidian     -> per-vault snippets/noctalia.css          (hook edits
            #                   each vault's own appearance.json)
            #   prismlauncher-> $XDG_DATA_HOME/PrismLauncher/themes/…     (no hook)
            #   zen-browser  -> $XDG_CACHE_HOME/noctalia/zen-browser/*    (hook
            #                   touches each Zen profile's own chrome/userChrome.css
            #                   + user.js — no longer home-manager-managed since the
            #                   in-browser transparency switch, so now safe)
            # neovim/tmux stay OUT of this list — their apply.sh rewrites a
            # managed init.lua / tmux.conf; handled as `user` templates below.
            enable_community_templates = true;
            community_ids = [
              "bat"
              "claude-code"
              "discord"
              "obs"
              "obsidian"
              "prismlauncher"
              "telegram"
              "yazi"
              "zed"
              "zen-browser"
            ];

            # `user` templates: apps whose upstream template would rewrite a
            # home-manager-managed (read-only) file. Each renders to a
            # non-managed path that the app then includes/requires/sources.
            #   kitty  -> reuses the builtin template from the noctalia store path
            #   neovim -> vendored copy of the community template (not in the store)
            #   tmux   -> vendored (no upstream template exists)
            # starship and fastfetch add their own `user.*` entries here too, from
            # home/features/cli/{starship,fastfetch}.nix (module-merged), since the
            # static config lives with those features.
            user = {
              kitty = {
                enabled = true;
                input_path = "${config.programs.noctalia.package}/share/noctalia/assets/templates/kitty/kitty.conf";
                output_path = "~/.config/noctalia/generated/kitty-colors.conf";
                # reload only — never touches the managed kitty.conf
                post_hook = "pkill -USR1 kitty || true";
              };
              neovim = {
                enabled = true;
                input_path = "${../../resources/noctalia-templates/nvim-matugen.lua}";
                # nvim/lua/ is not managed by nixvim (only init.lua is), so this
                # is require()-able as `matugen` without touching a managed file.
                output_path = "~/.config/nvim/lua/matugen.lua";
                post_hook = "pkill -SIGUSR1 nvim || true";
              };
              # No upstream template for tmux. tmux.conf (managed) does
              # `source-file -q` on this generated, non-managed file.
              tmux = {
                enabled = true;
                input_path = "${../../resources/noctalia-templates/tmux-colors.conf}";
                output_path = "~/.config/tmux/noctalia-colors.conf";
                post_hook = ''tmux source-file "$HOME/.config/tmux/noctalia-colors.conf" >/dev/null 2>&1 || true'';
              };
            };
          };
        };

        wallpaper = {
          enabled = true;
          directory = "${config.home.homeDirectory}/Wallpapers";
          # Default wallpaper (also what the palette is derived from on first
          # run). Runtime picks via the shell overwrite this in state.
          default.path = "${config.home.homeDirectory}/Wallpapers/gruvbox/forest.jpg";
        };

        # Plugins. vpn_switcher is a local plugin (files placed via xdg.dataFile
        # below); prismlauncher-instances comes from the community source repo.
        plugins = {
          enabled = [
            "pguin/vpn_switcher"
            "radimous/prismlauncher-instances"
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

        # Lock screen widgets disabled (login box only, no extra canvas widgets).
        lockscreen_widgets = {
          enabled = false;
          schema_version = 2;
        };

        # Top bar — docked flush to the top edge (no float): margin_edge /
        # margin_ends / radius all 0, corner-carve off, so it's an edge-to-edge
        # strip and panels drop straight out of it with no gap or rounded seam.
        # Solid (opaque) background so there's no translucency/blur mismatch
        # with the panels. Capsules keep widgets readable. Widget ids verified
        # against the live catalog; layout keys / enums validated by
        # `noctalia config validate` (checkConfig).
        # https://docs.noctalia.dev/noctalia/bar/
        bar.default = {
          position = "top";
          reserve_space = true; # keep an exclusive zone so windows never overlap it

          # Pinned to the top edge, full width, square.
          margin_edge = 0;
          margin_ends = 0;
          radius = 0;
          concave_edge_corners = false;

          thickness = 36;
          padding = 8;
          widget_spacing = 8;
          background_opacity = 1.0; # solid — matugen surface (near-black in dark mode)
          shadow = true;
          font_weight = 500;

          # Each widget in a subtle outlined capsule ("pill"), tinted with the
          # wallpaper-derived surface_variant role from matugen.
          capsule = true;
          capsule_fill = "surface_variant";
          capsule_opacity = 0.8;
          capsule_border = "outline";

          start = [
            "workspaces"
            "active_window"
          ];
          center = [
            "media"
            "clock"
          ];
          end = [
            "tray"
            "network"
            "pguin/vpn_switcher:widget"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "control-center"
          ];
        };

        # 24h time in the bar, full date on hover.
        widget.clock = {
          format = "{:%H:%M}";
          tooltip_format = "{:%A, %d %B %Y}";
        };

        # MPRIS now-playing capsule sitting left of the clock. Collapses when
        # nothing is playing so the centre stays clean; title scrolls on hover.
        widget.media = {
          hide_when_no_media = true;
          title_scroll = "on_hover";
          max_length = 220;
        };

        # Panels (launcher, clipboard, control-center…) kept readable — "soft"
        # ≈ 0.80 card opacity vs "glass" ≈ 0.55. The bar is the glass surface,
        # not the panels. Values: solid | soft | glass.
        shell = {
          font_family = "FiraCode";
          panel.transparency_mode = "soft";
          # Track per-app screen time (shown in the shell).
          screen_time_enabled = true;
        };
      };
    };
  };
}
