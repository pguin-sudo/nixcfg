{
  lib,
  fetchurl,
  appimageTools,
}:
let
  pname = "meshchatx";
  version = "4.7.2";

  src = fetchurl {
    url = "https://github.com/Quad4-Software/MeshChatX/releases/download/v${version}/ReticulumMeshChatX-v${version}-linux-x86_64.AppImage";
    sha256 = "sha256-jyXFTpbNPwZDtUoADNK22+nL6f3HbshUpYDMjNAB0DQ=";
  };

  appimage = appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs =
      pkgs: with pkgs; [
        alsa-lib
        at-spi2-atk
        at-spi2-core
        atk
        cairo
        cups
        dbus
        expat
        gdk-pixbuf
        glib
        gtk3
        libdrm
        libnotify
        libpulseaudio
        libuuid
        libxkbcommon
        mesa
        nspr
        nss
        pango
        systemd # для libudev
        xorg.libX11
        xorg.libXcomposite
        xorg.libXdamage
        xorg.libXext
        xorg.libXfixes
        xorg.libXrandr
        xorg.libxcb
        xorg.libXtst
        xorg.libXScrnSaver
        xdg-utils
        vulkan-loader
      ];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/meshchatx.desktop <<EOF
      [Desktop Entry]
      Name=MeshChatX
      GenericName=Reticulum MeshChatX
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
    homepage = "https://github.com/Quad4-Software/MeshChatX";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
})
