{
  config,
  pkgs,
  inputs,
  ...
}:
{
  users.users = {
    pguin = {
      initialHashedPassword = "$y$j9T$s9PbtEj4JfCxIy0sDAteX1$EEboz0oQmMWPS1VwdGcmCKqqlJ1LHgPNy/UiTX.VhQ2";
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
        "dialout"
      ];
      packages = [ inputs.home-manager.packages.${pkgs.system}.default ];

      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjA/t7FsSZ8CPPMXxNeJ9G2/NDm/tpesfTiVKh8C2ZAqXVdZvFpTV4Ngqgo0bLhGmzsliTSmvM7QX82Df5TXBd4BtIvkEFlhnk1QFJh/6CIMYUfly8B8buhtqdK7r5BEvgCton+b3ipny4m2w5v93zNqhV//cURhQJJhXax/vSuTn79P5iPnEjnj+VDl/Xzf8IVyiHm3NPa/VWQ2S2Me7FaifLF7dWsTy9mkqOTgfA1074aoeY/KUCxjz1GBt843dTkuxqpI+hP4Sv8ATEDzdItLOmXtwjkOXoLtYbsWLd17q94E/bIX9ewlJJMK4ZAgpztNnCJBhnAuHAYJQdjMgM9tsko11KZkscF+0fMA1VX21QscDTGH0smfN+LfBwJFMsqIBFZCwK0M1X4XOp3ETZQayr/tGVc2+4KUcpmYjcGuH4p6MdF6hSuJXHlzcajfThQeseXULvxSxdN3+8UJ5GwSGH6eRelf7Y55OBbi6utdzC+jNHwGUK7KPuX05KVw2kRKTyAT1hOc7QZI/nG5XzWJtNVT6YaTqGJot52tq0+NK1YKvi80s0fxX4dj0mElXIVeZlxByq2yQgvHwA5drmN9vTvFy4G2ScIPzm9Yhdc9+sg4czdclYLhSPJXcFX4dTND4orfTjoDaiptEwsRqJf5U1hPrtSUwXvR+N9OZiJw== pguin"
      ];
    };

    root = {
      openssh.authorizedKeys.keys = [ ];
      extraGroups = [ "key" ];
    };
  };

  #programs.wireshark = {
  #  enable = true;
  #  package = pkgs.wireshark;
  #};

  programs.amnezia-vpn.enable = true;

  programs.zsh.enable = true;

  home-manager.users.pguin = import ../../../home/pguin/${config.networking.hostName}.nix;
}
