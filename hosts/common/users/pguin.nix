{
  config,
  pkgs,
  inputs,
  ...
}: {
  users.users.pguin = {
    initialHashedPassword = "$y$j9T$MrNNeV8FZfAIBze1aBwoN/$jXaIlHQjUvicqre8ez3rPGBNi4TWIpp2DdiDfPGhJ/6";
    isNormalUser = true;
    description = "pguin";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
      "input"
    ];
    openssh.authorizedKeys.keys = [];
    packages = [inputs.home-manager.packages.${pkgs.system}.default]; 
  };
  home-manager.users.pguin = import ../../../home/pguin/${config.networking.hostName}.nix;
}
