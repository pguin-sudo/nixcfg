{ pkgs, ... }: {
  imports = [
    ./fzf.nix
    ./neofetch.nix
    ./zsh.nix
  ];

  # Starship
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = true;
    enableFishIntegration = true;
  };

  programs.bat = { enable = true; };

  home.packages = with pkgs; [
    coreutils
    fd
    htop
    ripgrep
    tldr
    zip
    exiftool
    chafa
    nvtopPackages.full
  ];
}
