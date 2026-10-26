{ pkgs, ... }:
{
  imports = [
    ./atuin.nix
    ./btop.nix
    ./fzf.nix
    ./fastfetch.nix
    ./neovim.nix
    ./starship.nix
    ./tmux.nix
    ./vpnctl.nix
    ./yazi.nix
    ./zsh.nix
  ];

  programs.bat = {
    enable = true;
    # Noctalia ships the matugen tmTheme via the `bat` community template (see
    # noctalia.nix) to ~/.config/bat/themes/noctalia.tmTheme and rebuilds the
    # bat cache. Selecting it here means the template's apply.sh finds
    # `--theme=noctalia` already present and never edits the file itself.
    config.theme = "noctalia";
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
    ggh

    # Moved from the broken features.cli.system-tools (its enable flag was
    # never set -- it actually gated on the tmux flag).
    wireguard-tools
    openvpn
    tcpdump
    dnsutils
  ];
}
