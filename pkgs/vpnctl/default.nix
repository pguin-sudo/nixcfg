{
  lib,
  python3,
}:
python3.pkgs.buildPythonApplication {
  pname = "vpnctl";
  version = "0.1.0";
  pyproject = true;

  src = ./.;

  build-system = [ python3.pkgs.hatchling ];

  dependencies = with python3.pkgs; [
    click
    rich
    requests
    tomli-w
  ];

  doCheck = false;

  meta = {
    description = "Unified CLI for AmneziaWG and sing-box (Remnawave) VPN profiles";
    mainProgram = "vpnctl";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
