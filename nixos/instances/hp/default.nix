# This is specalized config for a single computer
{ config, pkgs, ... }: {
  imports = [
    ../defaults.nix
    ../../modules/hyperland.nix
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "elitebook"; # Define your hostname.

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
