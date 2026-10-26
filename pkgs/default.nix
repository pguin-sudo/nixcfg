{ pkgs, ... }: {
  plight = pkgs.callPackage ./plight { };
  prismlauncher-cracked = pkgs.callPackage ./prismlauncher-cracked { };
  vpnctl = pkgs.callPackage ./vpnctl { };
  lampa-desktop = pkgs.callPackage ./lampa-desktop { };
}
