{
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  docker-compose,
  lib,
  customComposeYml ? ./docker-compose.yml,
}:
stdenv.mkDerivation rec {
  pname = "meshradar";
  version = "1.1";

  src = fetchFromGitHub {
    owner = "curlysasha";
    repo = "MeshRadar";
    rev = "v${version}";
    sha256 = "sha256-WwuEo/3u1DnZZcr0i6iPf5gt6hh48rUxTgmSI4N9qVM=";
  };

  nativeBuildInputs = [makeWrapper];

  buildInputs = [];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Copy main files
    mkdir -p $out/share/${pname}
    cp -r $src/* $out/share/${pname}

    # Replace docker-compose.yml with custom one
    rm -f $out/share/${pname}/docker-compose.yml
    cp ${customComposeYml} $out/share/${pname}/docker-compose.yml

    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper "${docker-compose}/bin/docker-compose" $out/bin/${pname} \
      --run "cd $out/share/${pname}" \
      --add-flags "up"

    # Create .desktop file for app launchers
    mkdir -p $out/share/applications
    cat > $out/share/applications/${pname}.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Name=MeshRadar
    Comment=Docker Compose wrapper for MeshRadar with custom configuration
    Icon=network-wired
    Exec=$out/bin/${pname}
    Terminal=true
    Categories=Network;Utility;
    EOF

    # Create icon (optional - using system icon for now)
    # mkdir -p $out/share/icons/hicolor/48x48/apps
    # cp $src/icon.png $out/share/icons/hicolor/48x48/apps/${pname}.png 2>/dev/null || true

    runHook postInstall
  '';

  meta = with lib; {
    description = "Docker Compose wrapper for MeshRadar with custom configuration";
    homepage = "https://github.com/curlysasha/MeshRadar";
    license = licenses.mit;
    maintainers = [];
    platforms = platforms.all;
  };
}
