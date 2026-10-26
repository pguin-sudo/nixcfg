{ ... }:
{
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
}
