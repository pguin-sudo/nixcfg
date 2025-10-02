{pkgs, ...}: {
  imports = [
    ./btop.nix
    ./fzf.nix
    ./neofetch.nix
    ./neovim.nix
    ./zsh.nix
  ];

  # Starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {enable = true;};

  home.packages = with pkgs; [
    coreutils
    fd
    ripgrep
    tldr
    zip
    exiftool
    chafa
    nvtopPackages.full
  ];
}
