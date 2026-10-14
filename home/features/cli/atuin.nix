{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.cli.atuin;
in
{
  options.features.cli.atuin.enable = mkEnableOption "enable atuin configuration";

  config = mkIf cfg.enable {
    programs.atuin = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        auto_sync = true;
        sync_frequency = "5m";
        sync_address = "https://atuin.pguin.ru";
        search_mode = "fuzzy";
        update_check = false;
      };
    };
  };
}
