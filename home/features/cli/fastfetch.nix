{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.fastfetch;

  fastfetchConfig = ''
            {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

      "logo": {
        "source": "nixos",
        "type": "builtin",
        "height": 18
      },

      "display": {
        "separator": " : "
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
in {
  options.features.cli.fastfetch = {
    enable = mkEnableOption "fastfetch";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      fastfetch
    ];

    home.file.".config/fastfetch/config.jsonc" = {
      text = fastfetchConfig;
      force = true;
    };
  };
}
