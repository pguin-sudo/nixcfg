{
  lib,
  fetchurl,
  appimageTools,
}: let
  pname = "prismlauncher-cracked";
  version = "11.0.3";

  src = fetchurl {
    url = "https://github.com/Diegiwg/PrismLauncher-Cracked/releases/download/${version}/PrismLauncher-Linux-x86_64.AppImage";
    sha256 = "sha256-dVlHFnLLs2+24hWdiUqW2aVtpWN3DcdLmC2Ekn7la+A=";
  };

  appimage = appimageTools.wrapType2 {
    inherit pname version src;

    extraPkgs = pkgs: [];

    extraInstallCommands = ''
      mkdir -p $out/share/applications
      cat > $out/share/applications/${pname}.desktop <<EOF
      [Desktop Entry]
      Name=Prism Launcher (Cracked)
      GenericName=Minecraft Launcher
      Comment=Custom launcher for Minecraft
      Exec=$out/bin/${pname}
      Icon=application-x-executable
      Terminal=false
      Type=Application
      Categories=Game;
      EOF
    '';
  };
in
  appimage.overrideAttrs (oldAttrs: {
    meta = with lib; {
      description = "Cracked build of Prism Launcher, a custom Minecraft launcher";
      homepage = "https://github.com/Diegiwg/PrismLauncher-Cracked";
      license = licenses.gpl3Only;
      platforms = ["x86_64-linux"];
    };
  })
