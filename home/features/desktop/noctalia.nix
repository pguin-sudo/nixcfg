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
  imports = [ inputs.noctalia.homeModules.default ];

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

          templates = {
            enable_builtin_templates = true;
            # No managed-file conflict — these write their own color files
            # (~/.config/gtk-*/noctalia.css, ~/.config/qt*ct/colors/noctalia.conf).
            builtin_ids = [
              "gtk3"
              "gtk4"
              "qt"
            ];

            # Community templates whose outputs land in NON-managed locations:
            #   zed  -> ~/.config/zed/themes/noctalia.json      (no post_hook)
            #   yazi -> ~/.config/yazi/flavors/noctalia.yazi/   (post_hook edits
            #           the NON-managed ~/.config/yazi/theme.toml)
            # Fetched from api.noctalia.dev and cached under
            # ~/.local/state/noctalia/community-templates/ on first enable, so
            # they only theme once cached (not pure-reproducible, but no conflict).
            enable_community_templates = true;
            community_ids = [
              "yazi"
              "zed"
              # zen-browser: writes userChrome/userContent CSS to the cache, then
              # its apply.sh @imports them into the (non-managed) Zen profile and
              # flips toolkit.legacyUserProfileCustomizations.stylesheets on.
              # Needs a Zen restart after the first apply.
              "zen-browser"
            ];

            # kitty (builtin) and neovim (community) are redeclared here because
            # their upstream post_hook rewrites a managed file (kitty.conf /
            # init.lua). Inputs: kitty reuses the builtin template shipped in the
            # noctalia store path; neovim uses a vendored copy of the community
            # template (community templates are not in the Nix store). Outputs go
            # to non-managed files that the app configs include/require.
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
        };

        # Top bar — floating glass: low background opacity + Hyprland blur on the
        # noctalia-bar-* layer (see hyprland.nix layerrule) frosts it, capsules
        # keep widgets readable. Widget ids verified against the live catalog
        # (docs.noctalia.dev/v5/bar/widgets/) and the shipped widget_factory.cpp;
        # layout keys against config_schema.cpp (BarConfig). NB: example.toml's
        # margin_h/margin_v are stale — the current schema uses margin_ends /
        # margin_edge. https://docs.noctalia.dev/v5/bar/
        bar.default = {
          position = "top";
          reserve_space = true; # keep an exclusive zone so windows never overlap it

          # Float it: lift off the top edge and inset the ends so it reads as a
          # rounded strip rather than a full-width slab.
          margin_edge = 6;
          margin_ends = 8;
          thickness = 36;
          radius = 16;
          padding = 8;
          widget_spacing = 8;
          background_opacity = 0.2; # glassy strip — the blur does the rest
          shadow = true;
          font_weight = 500;

          # Each widget in a subtle outlined capsule ("pill"), tinted with the
          # wallpaper-derived surface_variant role from matugen. Slightly
          # translucent so the frosted glass shows through, still legible.
          capsule = true;
          capsule_fill = "surface_variant";
          capsule_opacity = 0.8;
          capsule_border = "outline";

          # Left: workspaces + focused window. Center: clock. Right: status
          # cluster (tray, connectivity, audio, brightness, battery) + control center.
          start = [
            "workspaces"
            "active_window"
          ];
          center = [ "clock" ];
          end = [
            "tray"
            "network"
            "bluetooth"
            "volume"
            "brightness"
            "battery"
            "control-center"
          ];
        };

        # Per-widget tweak for a bar widget (keys per example.toml [widget.clock]):
        # 24h time in the bar, full date on hover.
        widget.clock = {
          format = "{:%H:%M}";
          tooltip_format = "{:%A, %d %B %Y}";
        };

        # Panels (launcher, clipboard, control-center…) kept readable — "soft"
        # ≈ 0.80 card opacity vs "glass" ≈ 0.55. The bar is the glass surface,
        # not the panels. Values: solid | soft | glass.
        shell = {
          font_family = "FiraCode";
          panel.transparency_mode = "soft";
        };
      };
    };
  };
}
