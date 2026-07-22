{ pkgs, ... }: {
  plight = pkgs.callPackage ./plight { };
  meshchatx = pkgs.callPackage ./meshchatx { };
  meshradar = pkgs.callPackage ./meshradar { };
  prismlauncher-cracked = pkgs.callPackage ./prismlauncher-cracked { };
}
