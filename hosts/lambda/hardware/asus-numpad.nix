{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.hardware.asus-numpad;
in {
  options.hardware.asus-numpad.enable = mkEnableOption "enable asus numpad options";
  config =
    mkIf cfg.enable
    {
      services.asus-numberpad-driver = {
        enable = true;
        layout = "um3406ka";
        wayland = true;
        runtimeDir = "/run/user/1000/";
        waylandDisplay = "wayland-0";
        ignoreWaylandDisplayEnv = false;
        config = {
          "activation_time" = "0.5";
        };
      };
    };
}
