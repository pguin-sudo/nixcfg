{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.starship;
in {
  options.features.cli.starship.enable = mkEnableOption "enable starship prompt";

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      settings = {
        format = "$all$character";
        palette = "universal";

        palettes.universal = {
          background = "#${config.colorScheme.palette.base00}";
          surface = "#${config.colorScheme.palette.base01}";
          muted = "#${config.colorScheme.palette.base03}";
          text = "#${config.colorScheme.palette.base05}";
          bright = "#${config.colorScheme.palette.base07}";
          accent1 = "#${config.colorScheme.palette.base08}";
          accent2 = "#${config.colorScheme.palette.base09}";
          accent3 = "#${config.colorScheme.palette.base0A}";
          accent4 = "#${config.colorScheme.palette.base0B}";
          accent5 = "#${config.colorScheme.palette.base0C}";
          accent6 = "#${config.colorScheme.palette.base0D}";
          accent7 = "#${config.colorScheme.palette.base0E}";
        };

        character = {
          success_symbol = "[❯](accent7)";
          error_symbol = "[❯](accent1)";
        };

        directory = {
          style = "accent6";
          truncation_length = 3;
          truncate_to_repo = false;
        };

        git_branch = {
          style = "accent7";
        };

        git_status = {
          style = "accent5";
        };

        cmd_duration = {
          style = "accent3";
        };

        hostname = {
          style = "accent4";
        };

        username = {
          style_user = "accent2";
        };
      };
    };
  };
}

