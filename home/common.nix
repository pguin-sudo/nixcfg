{
  config,
  lib,
  inputs,
  ...
}:
let
  # Zen (beta). Transparency is not wired from Nix: install the "Zen Internet"
  # mod from Zen's in-browser mod store (Settings -> Mods) and set
  # zen.widget.linux.transparency = true once in about:config. Hyprland
  # supplies the glass blur (see home/desktop/hyprland.nix, the zen-beta
  # windowrule).
  zenBeta = inputs.zen-browser.packages.x86_64-linux.default;
in
{
  imports = [
    ./cli
    ./desktop
    ./packages
  ];

  home.username = "pguin";
  home.homeDirectory = lib.mkDefault "/home/${config.home.username}";
  home.stateVersion = "24.05";

  home.packages = [ zenBeta ];

  home.sessionVariables = {
    BROWSER = "zen-beta";
    EDITOR = "nvim";
    XDG_CACHE_HOME = "${config.home.homeDirectory}/.cache";
    XDG_CONFIG_HOME = "${config.home.homeDirectory}/.config";
    XDG_BIN_HOME = "${config.home.homeDirectory}/.nix-profile/bin";
    XDG_DATA_HOME = "${config.home.homeDirectory}/.local/share";
  };

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    lfs.enable = true;
    settings = {
      user.name = "PGuin";
      user.email = "138515193+pguin-sudo@users.noreply.github.com";
      pull.rebase = true;
    };
  };

  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
  };
}
