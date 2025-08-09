{ inputs, lib, config, pkgs, unstable-pkgs, ... }: {

  imports = [
    ../defaults.nix
  ];

  # Set primary user for system defaults
  system.primaryUser = "erd";

  # Users
  users.users.vngrs = {
    name = "erd";
    home = "/Users/erd";
  };
}
