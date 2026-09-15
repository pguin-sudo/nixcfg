{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.features.themes.rgb;
  noctaliaCfg = config.features.desktop.noctalia;

  colorFile = "${config.xdg.configHome}/noctalia/generated/rgb-color.conf";

  # D_LED1/D_LED2 (zone 0 on this board) only reports LED_CPU/LED_C colors
  # correctly once its size is (re)declared -- otherwise -c is silently a
  # no-op on the physical strip.
  rgbScript = pkgs.writeShellScript "rgb-setup" ''
    color=$(tr -d '#\n' < "${colorFile}" 2>/dev/null)
    ${lib.getExe pkgs.openrgb} -d 0 -z 0 -sz 12 -c "''${color:-000000}" -m static
  '';
in {
  options.features.themes.rgb.enable = lib.mkEnableOption "rgb light";

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
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
    }
    (lib.mkIf noctaliaCfg.enable {
      programs.noctalia.settings.theme.templates.user.rgb = {
        enabled = true;
        input_path = "${../../resources/noctalia-templates/rgb-color.conf}";
        output_path = "~/.config/noctalia/generated/rgb-color.conf";
        post_hook = "systemctl --user restart rgb.service || true";
      };
    })
  ]);
}
