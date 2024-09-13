{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Stylix
    stylix.url = "github:danth/stylix";
    stylix.inputs.nixpkgs.follows = "nixpkgs";

    # NvChad -> Neovim config
    nvchad4nix = {
      url = "github:nix-community/nix4nvchad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    home-manager,
    stylix,
    ...
  } @ inputs: let
    inherit (self) outputs;
    unstable-pkgs = nixpkgs-unstable.legacyPackages.x86_64-linux;
  in {
    home-manager.extraSpecialArgs = {inherit nixpkgs-unstable;};

    nixosConfigurations = {
      excalibur = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [ stylix.nixosModules.stylix ./nixos/instances/excalibur ];
      };
      thinkpad-t430 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = {inherit inputs outputs;};
        modules = [ stylix.nixosModules.stylix ./nixos/instances/thinkpad-t430 ];
      };
    };

    # Standalone home-manager configuration entrypoint
    homeConfigurations = {
      erd = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = {inherit inputs outputs unstable-pkgs;};
        modules = [ stylix.nixosModules.stylix ./home-manager/home.nix ];
      };
    };
  };
}
