{ self, inputs, ... }:
{
  flake.darwinConfigurations.mac-personal = inputs.nix-darwin.lib.darwinSystem {
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
      self.darwinModules.darwinDefaults
      self.darwinModules.macPersonalConfiguration
      self.darwinModules.homebrew
    ];
  };

  flake.darwinModules.macPersonalConfiguration =
    { ... }:
    {
      system.primaryUser = "erd";

      users.users.erd.home = "/Users/erd";
    };
}
