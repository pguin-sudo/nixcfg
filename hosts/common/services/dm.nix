{
  config,
  lib,
  inputs,
  ...
}:
with lib;
let
  cfg = config.common.services.dm;
in
{
  options.common.services.dm.enable = mkEnableOption "enable dm";

  imports = [ inputs.noctalia-greeter.nixosModules.default ];

  # https://docs.noctalia.dev/v5/greeter/
  config = mkIf cfg.enable {
    programs.noctalia-greeter = {
      enable = true;
    };

    services.displayManager.defaultSession = "hyprland";

    # greetd (the login manager noctalia-greeter drives) picks this up
    # automatically for its PAM service.
    services.gnome.gnome-keyring.enable = true;

    programs.hyprland.enable = true;
  };
}
