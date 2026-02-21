{ config, pkgs, unstable-pkgs, ... }: {
  # Enable bluetooth (required for Noctalia)
  hardware.bluetooth.enable = true;

  # Enable UPower for battery monitoring (required for Noctalia)
  services.upower.enable = true;

  # Enable power profiles daemon (required for Noctalia)
  services.power-profiles-daemon.enable = true;
}
