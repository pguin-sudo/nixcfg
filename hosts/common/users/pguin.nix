{ config, pkgs, inputs, ... }: {
  users.users = {
    pguin = {  
      initialHashedPassword = "$y$j9T$MrNNeV8FZfAIBze1aBwoN/$jXaIlHQjUvicqre8ez3rPGBNi4TWIpp2DdiDfPGhJ/6";
      isNormalUser = true;
      shell = pkgs.zsh;
      description = "pguin";
      group = "users";
      extraGroups = [
        "wheel"
        "networkmanager"
        "libvirtd"
        "flatpak"
        "audio"
        "video"
        "plugdev"
        "input"
        "kvm"
        "qemu-libvirtd"
        "docker"
        "key"
        "wireshark"
      ];
      packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

      openssh.authorizedKeys.keys = [];
    };

    root = {
      openssh.authorizedKeys.keys = [];
      extraGroups = [ "key" ];
    };
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  programs.zsh.enable = true;

  home-manager.users.pguin =
    import ../../../home/pguin/${config.networking.hostName}.nix;
}
