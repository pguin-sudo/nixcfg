{
  inputs,
  pkgs,
  ...
}:
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  programs.spicetify = {
    enable = true;

    enabledExtensions = with inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.extensions; [
      adblock
      hidePodcasts
      shuffle
    ];

    enabledCustomApps = with inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system}.apps; [
      newReleases
    ];
  };
}
