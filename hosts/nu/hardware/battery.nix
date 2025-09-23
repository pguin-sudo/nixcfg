{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.hardware.battery;
in
{
  options.hardware.battery.enable = mkEnableOption "enable battery options";

  config = mkIf cfg.enable
    {
      # Better scheduling for CPU cycles - thanks System76!!!
      services.system76-scheduler.settings.cfsProfiles.enable = true;

      # Enable TLP (better than gnomes internal power manager)
      services.tlp = {
        enable = true;
        settings = {
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        };
      };

      # Do nothing if AC on
      services.logind.lidSwitchExternalPower = "ignore";

      # Disable GNOMEs power management
      services.power-profiles-daemon.enable = false;

      # Enable powertop
      #powerManagement.powertop.enable = true; # Using TLP

      # Enable thermald (only necessary if on Intel CPUs)
      services.thermald.enable = true;

      # Upower
      services.upower.enable = true;

      # Power Alerts
      environment.systemPackages = with pkgs; [
        poweralertd
      ];
    };


}
