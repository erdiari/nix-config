{ ... }: {
  flake.nixosModules.hyperland = { pkgs, unstable-pkgs, ... }: {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    programs.gnupg.agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
    };

    services.dbus.enable = true;
    services.dbus.packages = [ pkgs.gcr ];
    services.xserver.updateDbusEnvironment = true;

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with unstable-pkgs; [
        xdg-desktop-portal-termfilechooser
        kdePackages.xdg-desktop-portal-kde
      ];
    };

    environment.sessionVariables = {
      WLR_NO_HARDWARE_CURSORS = "1";
      NIXOS_OZONE_WL = "1";
    };

    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.systemPackages = with pkgs; [
      hyprland
      hyprpaper
      playerctl
      xwayland
      dunst
      rofi
      bemoji
      rofi-rbw-wayland
      rbw
      pinentry-gnome3
      gcr
      kitty
      networkmanagerapplet
    ];
  };
}
