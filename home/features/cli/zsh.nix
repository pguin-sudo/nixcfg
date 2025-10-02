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
        dotfilesu = "nix flake lock --update-input dotfiles";
        cleanold = "sudo nix-collect-garbage --delete-old";
        cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";
      };

      initContent = '''';

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
}
