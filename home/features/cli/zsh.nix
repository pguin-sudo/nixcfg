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

      history = {
        size = 10000;
        save = 10000;
        path = "${config.home.homeDirectory}/.zsh_history";
        extended = true;
        ignoreDups = true;
        ignoreSpace = true;
      };

      shellAliases = {
        nf = "nvim $(fzf)";
        rebuild = "notify-send \"Rebuild started\" && sudo nixos-rebuild switch --flake /home/pguin/nixcfg/#$(hostname) && notify-send \"Rebuild completed\"";

        cleanold = "sudo nix-collect-garbage --delete-old";
        cleanboot = "sudo /run/current-system/bin/switch-to-configuration boot";

        ls = "ls --color=auto";
        ll = "ls -la";
        grep = "grep --color=auto";
        ".." = "cd ..";
        "..." = "cd ../..";

        ssh = "kitty +kitten ssh";

        notepad = "nvim ~/Nextcloud/notepad";
        tiktok = "/home/pguin/Desktop/tiktok/tiktok.sh";
      };

      initContent = ''
        export PATH="$HOME/.local/bin:$PATH"
      '';

      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      enableCompletion = true;
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
  };
}
