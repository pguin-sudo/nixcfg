{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.suites.mesh;

  meshchat = pkgs.fetchurl {
    name = "meshchat-appimage";
    url = "https://github.com/liamcottle/reticulum-meshchat/releases/download/v2.2.1/ReticulumMeshChat-v2.2.1-linux.AppImage";
    sha256 = "sha256-Q88V+cbtdh1sbH6jjLGTOFSJ/SdUWXga/8mdvKzGldA=";
    executable = true;
  };

  meshchat-wrapper = pkgs.writeShellScriptBin "meshchat" ''
    exec "${meshchat}" "$@"
  '';
in {
  options.features.suites.mesh.enable = mkEnableOption "enable software for mesh networks";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      python313Packages.nomadnet
      python313Packages.lxmf
      rns
      meshchat-wrapper
    ];

    xdg.desktopEntries.meshchat = {
      name = "MeshChat";
      genericName = "Reticulum Mesh Chat";
      comment = "Decentralized mesh messaging client";
      exec = "meshchat";
      icon = "application-internet";
      terminal = false;
      categories = ["Network" "InstantMessaging"];
      type = "Application";
    };
  };
}
