{ self, inputs, ... }: {
  flake.darwinConfigurations.mac-intel = inputs.nix-darwin.lib.darwinSystem {
    system = "x86_64-darwin";
    specialArgs = {
      inherit inputs;
      unstable-pkgs = import inputs.nixpkgs-unstable {
        system = "x86_64-darwin";
        config.allowUnfree = true;
      };
    };
    modules = [
      { nixpkgs.config.allowUnfree = true; }
      self.nixosModules.darwinDefaults
      self.nixosModules.macPersonalConfiguration
    ];
  };

  flake.nixosModules.macPersonalConfiguration = { ... }: {
    system.primaryUser = "erd";

    users.users.vngrs = {
      name = "erd";
      home = "/Users/erd";
    };
  };
}
