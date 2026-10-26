{ pkgs, ... }:
let
  # The {{colors.*}} tokens are substituted by Noctalia's template engine (see
  # noctalia.nix). Noctalia owns ~/.config/fastfetch/config.jsonc so
  # home-manager must not also write it -- the shipped `fastfetch` community
  # template can't be used because its apply.sh runs config.jsonc through `jq`
  # (rejects our comments / $schema) and then rewrites the read-only file.
  fastfetchTemplate = pkgs.writeText "fastfetch-config.jsonc.in" ''
          {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

      "logo": {
        "source": "nixos",
        "type": "builtin",
        "height": 18,
        "color": {
          "1": "{{colors.primary.default.hex}}",
          "2": "{{colors.secondary.default.hex}}"
        }
      },

      "display": {
        "separator": " : ",
        "color": {
          "keys": "{{colors.primary.default.hex}}",
          "title": "{{colors.secondary.default.hex}}"
        },
        "percent": {
          "color": {
            "green": "{{colors.tertiary.default.hex}}",
            "yellow": "{{colors.primary_fixed_dim.default.hex}}",
            "red": "{{colors.error.default.hex}}"
          }
        }
      },

      "modules": [
        {
          "type": "custom",
          "format": "┌──────────────────────────────────────────┐"
        },
        {
          "type": "chassis",
          "key": "Chassis",
          "format": "{1} {2} {3}"
        },
        {
          "type": "os",
          "key": "OS",
          "format": "{2}"
        },
        {
          "type": "kernel",
          "key": "Kernel",
          "format": "{2}"
        },
        {
          "type": "packages",
          "key": "Packages"
        },
        {
          "type": "display",
          "key": "Display",
          "format": "{1}x{2} @ {3}Hz [{7}]"
        },
        {
          "type": "terminal",
          "key": "Terminal"
        },
        {
          "type": "wm",
          "key": "WM",
          "format": "{2}"
        },
        {
          "type": "custom",
          "format": "└──────────────────────────────────────────┘"
        },

        "break",

        {
          "type": "title",
          "key": "User",
          "format": "{0}@{1}"
        },
        {
          "type": "custom",
          "format": "┌──────────────────────────────────────────┐"
        },
        {
          "type": "cpu",
          "format": "{1} @ {7}",
          "key": "CPU"
        },
        {
          "type": "gpu",
          "format": "{1} {2}",
          "key": "GPU"
        },
        {
          "type": "gpu",
          "format": "{3}",
          "key": "GPU Driver"
        },
        {
          "type": "memory",
          "key": "Memory"
        },
        {
          "type": "uptime",
          "key": "Uptime"
        },
        {
          "type": "custom",
          "format": "└──────────────────────────────────────────┘"
        },

        "break",

        {
          "type": "colors",
          "symbol": "circle"
        }
      ]
    }
  '';
in
{
  home.packages = [ pkgs.fastfetch ];

  # Noctalia renders ~/.config/fastfetch/config.jsonc from fastfetchTemplate
  # on every theme change. Do NOT also manage it via home.file (read-only
  # symlink would break the template's write). Before Noctalia's first run
  # fastfetch just falls back to its built-in defaults.
  programs.noctalia.settings.theme.templates.user.fastfetch = {
    enabled = true;
    input_path = "${fastfetchTemplate}";
    output_path = "~/.config/fastfetch/config.jsonc";
    post_hook = "true";
  };
}
