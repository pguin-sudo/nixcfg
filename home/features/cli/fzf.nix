{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.fzf;
in {
  options.features.cli.fzf.enable = mkEnableOption "enable fuzzy finder";

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;

      tmux.enableShellIntegration = true;

      defaultOptions = [
        "--preview='bat --color=always -n {}'"
        "--bind 'ctrl-p:toggle-preview'"
      ];
      defaultCommand = "fd --type f --exclude .git --follow --hidden";
      changeDirWidgetCommand = "fd --type d --exclude .git --follow --hidden";
    };
  };
}
