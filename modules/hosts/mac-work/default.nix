{ self, inputs, ... }: {
  flake.darwinConfigurations.mac-m1 = inputs.nix-darwin.lib.darwinSystem {
    system = "aarch64-darwin";
    specialArgs = {
      inherit inputs;
      unstable-pkgs = import inputs.nixpkgs-unstable {
        system = "aarch64-darwin";
        config.allowUnfree = true;
      };
    };
    modules = [
      { nixpkgs.config.allowUnfree = true; }
      self.nixosModules.darwinDefaults
      self.nixosModules.macWorkConfiguration
    ];
  };

  flake.nixosModules.macWorkConfiguration = { ... }: {
    system.primaryUser = "erd";

    users.users.vngrs = {
      name = "erd";
      home = "/Users/erd";
    };
  };
}
