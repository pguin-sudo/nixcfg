{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.features.cli.tmux;
in
{
  options.features.cli.tmux.enable = mkEnableOption "enable tmux";

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;

      baseIndex = 1;

      mouse = true;
      shell = "${pkgs.zsh}/bin/zsh";
      keyMode = "vi";
      terminal = "tmux-256color";
      newSession = true;

      extraConfig = ''
        unbind-key -a -T root

        set -g pane-border-lines double

        set  -g base-index      1
        setw -g pane-base-index 1

        setw -g mode-keys   vi
        set  -g focus-events on

        set  -g mouse             on

        set  -s escape-time       0
        set  -g history-limit     2000

        set  -g default-terminal "tmux-256color"
        set -ag terminal-overrides ",xterm-256color:RGB,*256col*:RGB,alacritty:RGB,kitty:RGB"

        bind -n M-s choose-tree -s

        bind -n M-1 select-window -t 1
        bind -n M-2 select-window -t 2
        bind -n M-3 select-window -t 3
        bind -n M-4 select-window -t 4
        bind -n M-5 select-window -t 5
        bind -n M-6 select-window -t 6
        bind -n M-7 select-window -t 7
        bind -n M-8 select-window -t 8
        bind -n M-9 select-window -t 9

        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D

        bind -n M-S-Left resize-pane -L 5
        bind -n M-S-Right resize-pane -R 5
        bind -n M-S-Up resize-pane -U 3
        bind -n M-S-Down resize-pane -D 3

        bind -n M-h split-winjdow -v
        bind -n M-v split-window -h

        bind -n M-Enter new-window
        bind -n M-c kill-pane
        bind -n M-q kill-window

        bind -n M-d detach
        bind -n M-Q confirm-before -p "Kill entire session? (y/n)" kill-session

        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy || xclip -in -selection clipboard"

        bind -n M-/ copy-mode \; command-prompt -p "(search down)" "send -X search-forward '%%%'"
        bind -n M-? copy-mode \; command-prompt -p "(search up)"   "send -X search-backward '%%%'"

        bind -n WheelUpPane select-pane -t = \; copy-mode -e \; send-keys -M
        bind -n WheelDownPane select-pane -t = \; send-keys -M

        # STYLING
        set -g status-position top
        set -g status-left-length 100
        set -g status-left "#[fg=foregroundcolor,bold]#S #[fg=pipecolor,nobold]"
        set -g window-status-current-format "#[fg=windowcolor,bold] #I:#W"
        set -g window-status-forman "  #I:#W"
        set -g message-style "fg=messagecolor,bg=default"
        set -g mode-style "fg-modecolor,bg=mutedcolor"
        set -g pane-border-style "fg=modecolor"
        set -g pane-active-border-style "fg=mediumcolor"
      '';

      plugins = with pkgs; [
        {
          plugin = tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '10'
          '';
        }
      ];
    };
  };
}
