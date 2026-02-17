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
      inputs.nixpkgs.follows = "nixpkgs";
    };

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:nix-community/stylix";

    asus-numpad-driver = {
      url = "github:asus-linux-drivers/asus-numberpad-driver";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-howdy.url = "github:fufexan/nixpkgs/howdy";

    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      disko,
      nixos-hardware,
      nixvim,
      winapps,
      stylix,
      spicetify-nix,
      asus-numpad-driver,
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
            # Howdy
            { disabledModules = [ "security/pam.nix" ]; }
            "${howdy}/nixos/modules/security/pam.nix"
            "${howdy}/nixos/modules/services/security/howdy"
            "${howdy}/nixos/modules/services/misc/linux-enable-ir-emitter.nix"
            # Host config
            ./hosts/lambda
          ];
        };

        nu = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/nu
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
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            stylix.homeModules.stylix
            ./home/pguin/lambda.nix
          ];
        };

        "pguin@nu" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            stylix.homeModules.stylix
            ./home/pguin/nu.nix
          ];
        };
      };
    };
}
