{ lib, ... }:
{
  options.flake.modules = lib.mkOption {
    type = lib.types.attrsOf (lib.types.attrsOf lib.types.deferredModule);
    default = { };
  };

  # flake-parts declares nixosModules, but not homeModules; without a declared
  # option its freeform type rejects definitions from more than one file.
  options.flake.homeModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
  };

  # flake-parts declares nixosModules with _class = "nixos"; nix-darwin's
  # darwinSystem strictly requires _class = "darwin", so darwin aspects need
  # their own tagged registry rather than reusing nixosModules.
  options.flake.darwinModules = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.deferredModule;
    default = { };
    apply = lib.mapAttrs (name: value: {
      _class = "darwin";
      imports = [ value ];
    });
  };
}
