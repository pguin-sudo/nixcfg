# default.nix
{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation rec {
  pname = "meshradar";
  version = "unstable-2026-01-09";

  src = pkgs.fetchFromGitHub {
    owner = "curlysasha";
    repo = "MeshRadar";
    rev = "master";
    hash = "sha256-MiKV0VvrfmXPfG41yNGhWL7AXrWUrovmBNHXubz4cz4=";
  };

  installPhase = ''
    mkdir -p $out/share/meshradar
    cp -r ./* $out/share/meshradar

    # Overwrite docker-compose.yml with custom version
    install -D ${./docker-compose.yml} $out/share/meshradar/docker-compose.yml

    # Ensure entrypoint.sh is executable
    chmod +x $out/share/meshradar/entrypoint.sh

    mkdir -p $out/bin
    cat > $out/bin/meshradar <<EOF
    #!/bin/sh
    cd $out/share/meshradar
    ${pkgs.docker-compose}/bin/docker-compose up
    EOF
    chmod +x $out/bin/meshradar

    # Additional bin for terminal execution
    cat > $out/bin/meshradar-terminal <<EOF
    #!/bin/sh
    ${pkgs.gnome-terminal}/bin/gnome-terminal -- sh -c "cd $out/share/meshradar; ${pkgs.docker-compose}/bin/docker-compose up; exec bash"
    EOF
    chmod +x $out/bin/meshradar-terminal

    mkdir -p $out/share/applications
    cat > $out/share/applications/meshradar.desktop <<EOF
    [Desktop Entry]
    Name=MeshRadar
    Exec=$out/bin/meshradar
    Icon=$out/share/meshradar/ico.png
    Type=Application
    Categories=Network;
    Terminal=false
    EOF

    # Desktop entry for terminal version (e.g., for rofi launch with terminal)
    cat > $out/share/applications/meshradar-terminal.desktop <<EOF
    [Desktop Entry]
    Name=MeshRadar (Terminal)
    Exec=$out/bin/meshradar-terminal
    Icon=$out/share/meshradar/ico.png
    Type=Application
    Categories=Network;
    Terminal=true
    EOF
  '';

  meta = with pkgs.lib; {
    description = "Modern web interface for Meshtastic mesh network nodes";
    homepage = "https://github.com/curlysasha/MeshRadar";
    license = licenses.gpl3Plus;
    maintainers = [];
    platforms = platforms.linux;
  };
}
