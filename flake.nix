{
  description = ''
    PGuin Modular Nixos
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";
    nixos-hardware.url = "github:NixOS/nixos-hardware";

    nixvim = {
      url = "github:nix-community/nixvim";
    };

    stylix.url = "github:nix-community/stylix";

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    asus-numpad-driver = {
      url = "github:asus-linux-drivers/asus-numberpad-driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";

    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      nixos-hardware,
      nixvim,
      stylix,
      spicetify-nix,
      asus-numpad-driver,
      zen-browser,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      systems = [
        "aarch64-linux"
        "i686-linux"
        "x86_64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
      howdy = inputs.nixpkgs-howdy;
    in
    {
      packages = forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {
        installer = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ({ lib, ... }: {
              # Встроить флейк в ISO (read-only, install.sh сам скопирует в /tmp)
              environment.etc."nixcfg".source = ./.;

              # Авто-логин root на tty1 → сразу запускает установщик
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
            })
          ];
        };

        delta = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-pc
            ./hosts/delta
            disko.nixosModules.disko
          ];
        };

        lambda = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            # NixOS hardware
            nixos-hardware.nixosModules.common-cpu-amd
            nixos-hardware.nixosModules.common-cpu-amd-pstate
            nixos-hardware.nixosModules.common-gpu-amd
            nixos-hardware.nixosModules.common-pc
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.asus-battery
            asus-numpad-driver.nixosModules.default
            # Howdy (disabled due to incompatibility with new PAM module)
            # { disabledModules = [ "security/pam.nix" ]; }
            # "${howdy}/nixos/modules/security/pam.nix"
            # "${howdy}/nixos/modules/services/security/howdy"
            # "${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
            # Disko
            disko.nixosModules.disko
            ./hosts/lambda/partitioning.nix
            # Host config
            ./hosts/lambda
          ];
        };
      };

      homeConfigurations = {
        "pguin@delta" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            stylix.homeModules.stylix
            ./home/pguin/delta.nix
          ];
        };

        "pguin@lambda" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs zen-browser; };
          modules = [
            stylix.homeModules.stylix
            ./home/pguin/lambda.nix
          ];
        };
      };
    };
}
