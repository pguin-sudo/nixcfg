{pkgs, ...}: {
  plight = pkgs.callPackage ./plight {};
  meshchat = pkgs.callPackage ./meshchat {};
  meshradar = pkgs.callPackage ./meshradar {};
  prismlauncher-cracked = pkgs.callPackage ./prismlauncher-cracked {};
}
