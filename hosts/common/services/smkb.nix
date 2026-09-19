{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.common.services.smkb;
in
{
  options.common.services.smkb = {
    master = {
      enable = mkEnableOption "smkb-master (shares this machine's mouse/keyboard over WiFi to a slave)";
      user = mkOption {
        type = types.str;
        default = "pguin";
        description = "User whose systemd --user session runs smkb-master.";
      };
    };
    slave = {
      enable = mkEnableOption "smkb-slave (receives the shared mouse/keyboard from a master)";
      user = mkOption {
        type = types.str;
        default = "pguin";
        description = "User whose systemd --user session runs smkb-slave.";
      };
    };
  };

  config = mkIf (cfg.master.enable || cfg.slave.enable) {
    services.smkb = {
      inherit (cfg) master slave;
    };
  };
}
