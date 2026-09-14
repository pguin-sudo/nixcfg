{
  lib,
  stdenvNoCC,
  fetchzip,
  autoPatchelfHook,
  makeWrapper,
  asar,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  gdk-pixbuf,
  glib,
  gtk3,
  libdrm,
  libGL,
  libnotify,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  libxscrnsaver,
  libxtst,
  mesa,
  nspr,
  nss,
  pango,
  systemd,
}:
let
  pname = "lampa-desktop";
  version = "1.5.10";
in
stdenvNoCC.mkDerivation {
  inherit pname version;

  # There is no AppImage release for this project (checked the release
  # assets 2026-09-13: only a Windows installer, an unpackaged linux-x64 zip
  # and a .deb are published). The zip is electron-builder's flat
  # "linux-unpacked" dump -- same contents an AppImage would wrap, just not
  # squashfs'd -- so it's unpacked and patched the same way appimageTools
  # would, by hand.
  src = fetchzip {
    url = "https://github.com/GideonWhite1029/lampa-desktop/releases/download/v${version}/Lampa-linux-x64-${version}.zip";
    hash = "sha256-dh9FGELGDuIrPxP/Tu5py/pEPORvP3TQSkT1J8p1HzM=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    asar
  ];

  # Standard Electron/Chromium runtime deps, as used by other unofficial
  # Electron packages unpacked from a zip/AppImage rather than nixpkgs-built.
  buildInputs = [
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
    libGL
    libnotify
    libxkbcommon
    mesa
    nspr
    nss
    pango
    systemd
    libx11
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxrandr
    libxcb
    libxtst
    libxscrnsaver
  ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/lampa-desktop
    cp -r . $out/opt/lampa-desktop/

    # The zip's top level has 8 executable files: the real "lampa" binary
    # plus chrome-sandbox, chrome_crashpad_handler and 5 executable .so libs
    # (confirmed by extracting v1.5.10). Prefer the known name; fall back to
    # scanning for anything else in case a future release renames it.
    mainProgram="$out/opt/lampa-desktop/lampa"
    if [ ! -x "$mainProgram" ]; then
      mainProgram="$(find $out/opt/lampa-desktop -maxdepth 1 -type f -executable \
        ! -name '*.so' ! -name 'chrome-sandbox' ! -name 'chrome_crashpad_handler' | head -n1)"
    fi
    if [ -z "$mainProgram" ] || [ ! -x "$mainProgram" ]; then
      echo "lampa-desktop: no top-level executable found in the release zip" >&2
      exit 1
    fi

    mkdir -p $out/bin
    # --no-sandbox: the store's chrome-sandbox helper isn't setuid-root here,
    # so Chromium's own sandbox can't init; trading it off is standard for
    # unofficial Electron packages built this way (not via nixpkgs' wrapper).
    #
    # LD_LIBRARY_PATH -> libGL (libglvnd): the app's own bundled libEGL.so/
    # libGLESv2.so (Chromium's ANGLE build) fail at load with "undefined
    # symbol: eglExportDMABUFImageMESA" and friends -- they're a stub ANGLE
    # never finished linking against a real driver. glibc's dlopen() search
    # order puts LD_LIBRARY_PATH before the binary's own RUNPATH (which lists
    # the app's directory first), so this makes the real vendor-dispatching
    # libEGL.so.1/libGLESv2.so.2 from libglvnd win instead -- confirmed via
    # LD_DEBUG=libs that this clears the ANGLE init errors entirely.
    makeWrapper "$mainProgram" $out/bin/lampa-desktop \
      --add-flags "--no-sandbox" \
      --set-default NIXOS_OZONE_WL 1 \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libGL ]}"

    # No loose icon file ships outside resources/app.asar (electron-builder's
    # packed app bundle) -- pull the app's own icon out of it for the desktop
    # entry (features/desktop/lampa.nix). Path confirmed via `asar list` on
    # the v1.5.10 release.
    # extract-file takes no destination arg -- it always writes to CWD, named
    # by the archive-internal path's basename.
    asar extract-file $out/opt/lampa-desktop/resources/app.asar icons/og.png
    install -Dm444 og.png $out/share/icons/hicolor/512x512/apps/lampa-desktop.png

    runHook postInstall
  '';

  meta = {
    description = "Unofficial Electron desktop client for the LAMPA media center";
    homepage = "https://github.com/GideonWhite1029/lampa-desktop";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "lampa-desktop";
  };
}
