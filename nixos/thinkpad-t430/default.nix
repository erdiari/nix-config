# This is specalized config for a single computer
{ config, pkgs, ... }: 

{
  imports = [
    ../defaults.nix
    ./hardware-configuration.nix
  ];
  
  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;


  networking.hostName = "thinkpad-t430";
}
