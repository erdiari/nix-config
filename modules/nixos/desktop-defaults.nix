{ ... }:
let
  desktopDefaults =
    { pkgs, ... }:
    {
      programs.kdeconnect.enable = true;

      services.displayManager.noctalia-greeter = {
        enable = true;
        settings.keyboard.layout = "tr";
      };

      services.desktopManager.plasma6.enable = true;
      environment.plasma6.excludePackages = [ pkgs.kdePackages.ksshaskpass ];

      services.xserver = {
        xkb.layout = "tr";
        xkb.variant = "";
      };

      services.printing.enable = true;

      programs.steam = {
        enable = true;
        gamescopeSession.enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
      };
      programs.gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
in
{
  flake.modules.nixos.desktopDefaults = desktopDefaults;
  flake.nixosModules.desktopDefaults = desktopDefaults;
}
