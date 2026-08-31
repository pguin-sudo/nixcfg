{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.btop;
in {
  options.features.cli.btop.enable = mkEnableOption "enable extended btop configuration";

  config = mkIf cfg.enable {
    programs.btop = {
      enable = true;
      settings = {
        theme_background = false;
        # Use Noctalia's matugen palette. The `btop` builtin template (see
        # noctalia.nix) writes ~/.config/btop/themes/noctalia.theme; setting the
        # selector here means its apply.sh finds it already set and never has to
        # edit our read-only btop.conf.
        color_theme = "noctalia";
      };
    };
  };
}
