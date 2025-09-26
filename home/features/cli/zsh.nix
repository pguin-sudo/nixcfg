{ config
, lib
, ...
}:
with lib; let
  cfg = config.features.cli.zsh;
in
{
  options.features.cli.zsh.enable = mkEnableOption "enable extended zsh configuration";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;

      # loginExtra = ''
      #   set -x NIX_PATH nixpkgs=channel:nixos-unstable
      #   set -x NIX_LOG info
      #   set -x TERMINAL kitty
      #
      #   if test (tty) = "/dev/tty1"
      #     exec Hyprland &> /dev/null
      #   end
      # '';

      shellAliases = {
        rebuild = "sudo nixos-rebuild switch --flake /home/pguin/nixcfg/#$(hostname)";
        dotfilesu = "nix flake lock --update-input dotfiles";
        cleanold = "sudo nix-collect-garbage --delete-old";
        cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";
      };

      initContent = lib.mkBefore ''
        unsetopt beep
        path+=('/home/pguin/.local/bin')
      '';

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
        zplug = {
        enable = true;
        plugins = [
          { name = "zsh-users/zsh-autosuggestions"; }
          { name = "zsh-users/zsh-syntax-highlighting"; }
          { name = "romkatv/zsh-defer"; }
        ];
      };
    };
  };
}
