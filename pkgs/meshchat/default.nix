{
  lib,
  fetchurl,
  appimageTools,
}: let
  pname = "meshchat";
  version = "2.2.1";

  src = fetchurl {
    url = "https://github.com/liamcottle/reticulum-meshchat/releases/download/v${version}/ReticulumMeshChat-v${version}-linux.AppImage";
    #sha256 = "sha256-Q88V+cbtdh1sbH6jjLGTOFSJ/SdUWXga/8mdvKzGldA=";
    sha256 = "sha256-nY7FaPte3YvJzz5SJ1CasEIDRpAOjS4sk1vdHMGBvUQ=";
  };

  appimage = appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: [];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/meshchat.desktop <<EOF
      [Desktop Entry]
      Name=MeshChat
      GenericName=Reticulum Mesh Chat
      Comment=Decentralized mesh messaging client
      Exec=$out/bin/${pname}
      Icon=application-internet
      Terminal=false
      Type=Application
      Categories=Network;InstantMessaging;
      EOF
    '';
  };
in
  appimage.overrideAttrs (oldAttrs: {
    meta = with lib; {
      description = "Decentralized mesh messaging client for Reticulum";
      homepage = "https://github.com/liamcottle/reticulum-meshchat";
      license = licenses.mit;
      platforms = ["x86_64-linux"];
    };
  })
