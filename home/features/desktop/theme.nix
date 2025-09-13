{
  pkgs,
  inputs,
  ...
}: {
  colorScheme = inputs.nix-colors.colorSchemes.dracula;
  qt = {
    enable = true;
    platformTheme = "gtk";
  };
  gtk = {
    enable = true;
    theme = {
      name = "Dracula";
      package = pkgs.dracula-theme;
    };
    iconTheme = {
      name = "Dracula";
      package = pkgs.dracula-icon-theme;
    };
  };
}

