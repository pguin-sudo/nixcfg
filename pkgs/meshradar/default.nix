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
  version = "serial-choose";
  src = fetchFromGitHub {
    owner = "curlysasha";
    repo = "MeshRadar";
    rev = "dd930151b04ccc8ba6009f9300af301886d6efa6";
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

    # Fix line endings in entrypoint.sh using tr
    tr -d '\r' < $out/share/${pname}/entrypoint.sh > temp.sh
    mv temp.sh $out/share/${pname}/entrypoint.sh

    # Set shebang to /bin/sh
    chmod +x $out/share/${pname}/entrypoint.sh

    # Fix other scripts if present
    if [ -f $out/share/${pname}/dev.sh ]; then
      tr -d '\r' < $out/share/${pname}/dev.sh > temp_dev.sh
      mv temp_dev.sh $out/share/${pname}/dev.sh
      sed -i '1s|.*|#!/bin/sh|' $out/share/${pname}/dev.sh
      chmod +x $out/share/${pname}/dev.sh
    fi

    # Replace docker-compose.yml with custom one
    rm -f $out/share/${pname}/docker-compose.yml
    cp ${customComposeYml} $out/share/${pname}/docker-compose.yml

    # Create executable wrapper
    mkdir -p $out/bin
    makeWrapper "${docker-compose}/bin/docker-compose" $out/bin/${pname} \
      --run "cd $out/share/${pname}" \
      --set COMPOSE_DOCKER_CLI_BUILD 0 \
      --add-flags "up -d --build"

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
