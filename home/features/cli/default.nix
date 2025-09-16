{
  pkgs,
  ...
}: {
  imports = [
    ./neovim.nix
    ./starship.nix
    ./pentest.nix
];

  programs.eza.enable = true;
  programs.bat.enable = true;

  home.packages = with pkgs; [
    coreutils
    fd
    htop
    zip
  ];
}

