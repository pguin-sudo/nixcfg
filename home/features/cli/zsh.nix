{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.zsh;
in {
  options.features.cli.zsh.enable = mkEnableOption "enable extended zsh configuration";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;

      shellAliases = {
        nf = "nvim $(fzf)";
        rebuild = "sudo nixos-rebuild switch --flake /home/pguin/nixcfg/#$(hostname)";
        cleanold = "sudo nix-collect-garbage --delete-old";
        cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";

        ssh = "kitty +kitten ssh";

        notepad = "~/Documents/notepad/sync.sh && nvim ~/Documents/notepad && (~/Documents/notepad/sync.sh > /dev/null 2>&1 &)";
      };

      initContent = ''
      '';

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
