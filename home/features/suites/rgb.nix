{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.themes.rgb;

  schemeContent = builtins.readFile config.stylix.base16Scheme;

  parseColor = colorName: lib.head (builtins.match ".*${colorName}:[[:space:]]*\"([^\"]*)\".*" schemeContent);

  setColor = color: "${lib.getExe pkgs.openrgb} --client -c ${lib.removePrefix "#" color} -m static";

  rgbScript = pkgs.writeShellScript "rgb-setup" ''
    ${setColor (parseColor "base0A")}
  '';
in {
  options.features.themes.rgb.enable = lib.mkEnableOption "rgb light";

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.openrgb];

    systemd.user.services.rgb = {
      Unit = {
        Description = "Set RGB colors to match scheme";
        After = ["graphical-session.target"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${rgbScript}";
        RemainAfterExit = true;
        ExecStartPre = "${pkgs.coreutils}/bin/sleep 5";
      };
      Install.WantedBy = ["graphical-session.target"];
    };
  };
}
