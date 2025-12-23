{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.hardware.battery;
in {
  options.hardware.battery.enable = mkEnableOption "enable battery options";
  config =
    mkIf cfg.enable
    {
      # Enable TLP (better than gnomes internal power manager)
      services.tlp = {
        enable = true;
        settings = {
          CPU_BOOST_ON_AC = 1;
          CPU_BOOST_ON_BAT = 0;
          CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          PLATFORM_PROFILE_ON_AC = "performance";
          PLATFORM_PROFILE_ON_BAT = "low-power";
          RADEON_DPM_PERF_LEVEL_ON_AC = "auto";
          RADEON_DPM_PERF_LEVEL_ON_BAT = "low";
          START_CHARGE_THRESH_BAT0 = 60;
          STOP_CHARGE_THRESH_BAT0 = 80;
        };
      };
      # Do nothing if AC on
      services.logind.lidSwitchExternalPower = "ignore";
      # Disable GNOMEs power management
      services.power-profiles-daemon.enable = false;
      # Enable powertop
      #powerManagement.powertop.enable = true; # Using TLP
      # Thermald is not necessary for AMD CPUs
      #services.thermald.enable = true;
      # Upower
      services.upower.enable = true;
      # Power Alerts
      environment.systemPackages = with pkgs; [
        poweralertd
      ];
    };
}
