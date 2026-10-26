{ pkgs, ... }:
{
  imports = [
    ./development.nix
    ./gaming.nix
    ./multimedia.nix
    ./pentest.nix
    ./productivity.nix
  ];

  # Not tied to any suite -- a plain mesh networking browser shortcut.
  home.packages = [ pkgs.chromium ];
}
