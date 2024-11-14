{
  config,
  pkgs,
  ...
}: {
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  services.dbus.enable = true;
  services.dbus.packages = [pkgs.gcr];
  services.xserver.updateDbusEnvironment = true; # This ensures that necessary environment variables are set

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # If gnome is installed, this is defined. No need to define twice
    # extraPortals = [
    #   pkgs.xdg-desktop-portal-gtk
    # ];
  };

  environment.sessionVariables = {
    # If your cursor becomes invisible
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  # Enable sound with pipewire.
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages = with pkgs; [
    hyprland
    swww # for wallpapers
    # hyprpaper # for wallpapers
    playerctl # for multimedia control
    xwayland # for opening x-apps
    dunst # for messages
    rofi-wayland # opening apps
    bemoji # rofi emoji plugin
    rofi-rbw-wayland # rofi bitwarden plugin
    rbw # bitwarden cli
    pinentry-gnome3 # required for rbw
    gcr
    kitty # default terminal
    networkmanagerapplet # for controlling network
    (waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))
  ];
}
