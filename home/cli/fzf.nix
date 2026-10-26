{ ... }:
{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    tmux.enableShellIntegration = true;

    historyWidget.command = "";
    defaultOptions = [
      "--preview='bat --color=always -n {}'"
      "--bind 'ctrl-p:toggle-preview'"
    ];
    defaultCommand = "fd --type f --exclude .git --follow --hidden";
    changeDirWidget.command = "fd --type d --exclude .git --follow --hidden";
  };
}
