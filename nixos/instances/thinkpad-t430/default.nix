# This is specalized config for a single computer
{ config, pkgs, ... }: {
  imports = [
    ../defaults.nix
    ../../modules/hyperland.nix
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  services.thermald.enable = true;

  networking.hostName = "thinkpad-t430";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
