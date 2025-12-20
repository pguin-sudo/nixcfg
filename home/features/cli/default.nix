{pkgs, ...}: {
  imports = [
    ./btop.nix
    ./fzf.nix
    ./fastfetch.nix
    ./neovim.nix
    ./system-tools.nix
    ./tmux.nix
    ./zsh.nix
  ];

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
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
    nvtopPackages.full
    tree
    file
  ];
}
