{
  description = ''
    PGuin Modular Nixos
  '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs"; # Pin sops-nix to follow nixpkgs
    };
    arion = {
      url = "github:hercules-ci/arion";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko.url = "github:nix-community/disko";

    nvf.url = "github:notashelf/nvf";

    winapps = {
      url = "github:winapps-org/winapps";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dotfiles = {
      url = "github:pguin-sudo/dotfiles";
      flake = false;
    };
  };



  outputs = { self, home-manager, nixpkgs, dotfiles, sops-nix, arion, disko, nvf, winapps, ... }@inputs:
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
    in
    {
      packages =
        forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      overlays = import ./overlays { inherit inputs; };
      nixosConfigurations = {

        delta = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/delta
            sops-nix.nixosModules.sops
            arion.nixosModules.arion
            ({ pkgs, outputs, ... }: {
              environment.systemPackages = with pkgs; [
                inputs.winapps.packages.${system}.winapps
                inputs.winapps.packages.${system}.winapps-launcher  
              ];
            })
          ];
        };
            
	nu = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit inputs outputs; };
          modules = [
            ./hosts/nu
            sops-nix.nixosModules.sops
            arion.nixosModules.arion
          ];
        };
      };

      homeConfigurations = {
        "pguin@delta" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            nvf.homeManagerModules.default
            ./home/pguin/delta.nix
          ];
        };

        "pguin@nu" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages."x86_64-linux";
          extraSpecialArgs = { inherit inputs outputs; };
          modules = [
            nvf.homeManagerModules.default
            ./home/pguin/nu.nix
          ];
        };

      };
    };
}
