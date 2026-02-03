{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.features.cli.zsh;
in
{
  options.features.cli.zsh.enable = mkEnableOption "enable extended zsh configuration";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;

      shellAliases = {
        nf = "nvim $(fzf)";
        rebuild = "notify-send \"Rebuild started\" && sudo nixos-rebuild switch --flake /home/pguin/nixcfg/#$(hostname) && notify-send \"Rebuild completed\"";

        cleanold = "sudo nix-collect-garbage --delete-old";
        cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";

        ssh = "kitty +kitten ssh";

        notepad = "nvim ~/Nextcloud/notepad";
      };

      initContent = '''';

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
