{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.tmux;
in {
  options.features.cli.system-tools.enable = mkEnableOption "enable networking tools";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Network Utilities (system-level)
      wireguard-tools
      openvpn
      #mullvad-vpn
      #speedtest-go
    ];
  };
}
