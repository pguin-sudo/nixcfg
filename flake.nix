{
  description = ''
    PGuin Modular Nixos
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zapret2-nix = {
      url = "github:ZenonEl/zapret2-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";

    smkb.url = "github:pguin-sudo/smkb";

    incy-nix.url = "github:pguin-sudo/incy-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      nixos-hardware,
      zapret2-nix,
      incy-nix,
      smkb,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      packages.x86_64-linux = import ./pkgs { pkgs = nixpkgs.legacyPackages.x86_64-linux; };

      nixosConfigurations = {
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            (
              { lib, ... }:
              {
                environment.etc."nixcfg".source = ./.;

                services.getty.autologinUser = lib.mkForce "root";

                systemd.services.nixos-pguin-installer = {
                  description = "pguin NixOS installer";
                  after = [
                    "network-online.target"
                    "getty.target"
                  ];
                  wants = [ "network-online.target" ];
                  wantedBy = [ "multi-user.target" ];
                  serviceConfig = {
                    Type = "idle";
                    StandardInput = "tty";
                    TTYPath = "/dev/tty1";
                    StandardOutput = "tty";
                    StandardError = "tty";
                    ExecStart = "/etc/nixcfg/install.sh";
                    Restart = "on-failure";
                  };
                };

                # Wifi через NetworkManager
                networking.networkmanager.enable = true;

                # SSH для отладки
                services.openssh = {
                  enable = true;
                  settings.PermitRootLogin = "yes";
                };

                nix.settings.experimental-features = [
                  "nix-command"
                  "flakes"
                ];
              }
            )
          ];
        };

        delta = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-pc
            ./hosts/delta
            disko.nixosModules.disko
            zapret2-nix.nixosModules.default
            incy-nix.nixosModules.default
            smkb.nixosModules.smkb
          ];
        };

        lambda = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixos-hardware.nixosModules.common-gpu-amd
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.asus-battery
            disko.nixosModules.disko
            ./hosts/lambda
            zapret2-nix.nixosModules.default
            incy-nix.nixosModules.default
            smkb.nixosModules.smkb
          ];
        };
      };
    };
}
