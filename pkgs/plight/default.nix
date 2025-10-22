{
  lib,
  stdenv,
  pkg-config,
  rustPlatform,
  fetchFromGitHub,
  dbus,
  udev,
  pipewire,
  llvmPackages,
  libxcb,
  xorg,
}:
rustPlatform.buildRustPackage {
  pname = "plight";
  version = "0.2.0-dev";

  src = fetchFromGitHub {
    owner = "pguin-sudo";
    repo = "plight";
    rev = "addb94bb37eeabb4adf76a7fe434277c1c91aa83";
    hash = "sha256-GWraAsLEQW5prmbNrA4OypLOfgYO1MpqTae2hTv1Yto=";
  };

  cargoHash = "sha256-esNxp4MCV50q49MBMCodvyTOpDun36ID1Oqfv+UC9EE=";

  nativeBuildInputs = [pkg-config llvmPackages.clang];

  buildInputs = [
    pipewire
    dbus
    udev
    llvmPackages.libclang
    stdenv.cc.libc
    libxcb
    xorg.libX11
  ];

  LIBCLANG_PATH = "${llvmPackages.libclang.lib}/lib";
  NIX_CFLAGS_COMPILE = "-isystem ${stdenv.cc.libc.dev}/include";

  meta = with lib; {
    description = "A configurable program for organizing dynamic backlighting";
    homepage = "https://github.com/pguin-sudo/plight";
    license = licenses.gpl3Only;
    maintainers = ["pguin-sudo"];
    platforms = platforms.linux;
  };
}
