{pkgs, ...}: {
  plight = pkgs.callPackage ./plight {};
  meshchat = pkgs.callPackage ./meshchat {};
}
