{ pkgs, ... }:
{
  imports = [
    ./btop.nix
    ./fzf.nix
    ./fastfetch.nix
    ./neovim.nix
    ./starship.nix
    ./system-tools.nix
    ./tmux.nix
    ./vpnctl.nix
    ./yazi.nix
    ./zsh.nix
  ];

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    # Noctalia ships the matugen tmTheme via the `bat` community template (see
    # noctalia.nix) to ~/.config/bat/themes/noctalia.tmTheme and rebuilds the
    # bat cache. Selecting it here means the template's apply.sh finds
    # `--theme=noctalia` already present and never edits the file itself.
    config.theme = "noctalia";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  home.packages = with pkgs; [
    coreutils
    fd
    ripgrep
    tldr
    zip
    unzip
    exiftool
    chafa
    tree
    file
    jq
  ];
}
