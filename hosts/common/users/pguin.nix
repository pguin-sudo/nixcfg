{
  config,
  pkgs,
  inputs,
  ...
}: {
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
        "dialout"
      ];
      packages = [inputs.home-manager.packages.${pkgs.system}.default];

      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNZDApTINXd8vmQBU1QrKqQDu5j3uprBxPIxFnR2iE9Ax9rDV4hjjxxZmFiqJYgrucpot+vg8exCp6nLqYEg61bNRo4rX6a2+hRwLSqB3dXvf1sVMNyvzazB9dUuQ1ukeOz8o77BacyrPST27jV77sErWCsp7BuH7xNpjc0+CZV4+YklDbhp25QXlYb9b+LAkxkK0PUMJcX5FEwfV2zmTYhyWYDLLhezxM0PxvQVpgvThIApt0rm+eDbNC7BfIyqVvnZkEptPCAh23e/yXA0mBI5XybPuiqdm+Fej5gvAV6IuGIF08ugsX058tq+f0kFAgdnlCbsLPQGREwfLEA1MAQ/t2R8uCVLgVKWJcPSN09OBB44B7eDE5q8sqvEnx4eqxulmVVXGpSfHgdnSCI2qovZgNKdio2pU/qzx8Ld4kkKbpa+Z1Q1QF5z+A+CdV3M54Y0XzpmXu8ZFwjwHSCui9Yae9cDMBOZc9dB6NIUHZIOeutcCCoaT7OnovUYHGLfS0+Oj1kpyBvrtp4zvuxQxPdS+lqFaaMDFldrud9FlfmxhcAGKGcEKKA01eDgh3DbeGcSxV8FCUPZT09iM9GQiOOH2AkgqCpSMU7M+oO+USRyWI1im6l20yRS695l41J5nuzMbRhST8bCqNjoTHM7blPYpxjp/uW2Lrbq2SOtJq3w== pguin@netbook" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDg35bwTcpb6BRg3d8nIyLZncOhIiCpzOtp0JUVx9Fw8HQPyZO+39Pg7c2YhwJIcWuhTTSELlOMk4nafg7Xork+hI8aC3dq/i22pRcv69sd2INWnmvuVsMu3Al2RTwTBQEOQfmbz4UrYzIP82iOF2PsTwXuLwWI6wNzv13B39ztirjnftTg3DhI5V0xQI4LgvWd9mTWrCofrVIvZ6HxOeV4nJKA+f+HHhSUxRLfvzBE2eAyxnnUTX/MgSftBSMUrExvzip75LopqZf0AGDtrhkUyzb2ufmffAb+zWwLxM4lVTwuICZnovemD+Bg0kSoBaW2BHOfIIFau69mo99lezQZepNGzc0Vc/erBDTpLSYbC8eYjKU1QFvIsFzeol5GN3+bOLIfTK7UKBykNPUYlP+LaLc5KDnGVsq2a5x2XzSrztpG9BRgnP8d0DdFtuDbGsXbO0raeNaPwpGIBH6FhKLn6fgTX4xFUAMfitfG4fQdN0q8A76CDuQfArVl2/Y9QfJZZ6a0sGYc13jpZi3Yo6mY+koeFeTxN/8VGn+zxm02SWeWBfy/YOqVyQjo2qiXzL8i6Hf+Bk0eleNzE33qMFgXDWvwwfxIGpA2X2Ffrn2vcvtTu7X44i1dKX1J8fhgH+u/xArBYg55FSLZUz2dYuIuuraK2cjd3nJDYr80k6wdXQ== pguin@iPhone"];
    };

    root = {
      openssh.authorizedKeys.keys = [];
      extraGroups = ["key"];
    };
  };

  programs.wireshark = {
    enable = true;
    package = pkgs.wireshark;
  };

  programs.zsh.enable = true;

  home-manager.users.pguin =
    import ../../../home/pguin/${config.networking.hostName}.nix;
  home-manager.extraSpecialArgs = {inherit inputs;};
}
