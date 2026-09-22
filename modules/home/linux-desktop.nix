{ inputs, ... }:
let
  linuxDesktop =
    {
      pkgs,
      unstable-pkgs,
      ...
    }:
    {
      imports = [ inputs.self.modules.homeManager.noctalia ];

      programs.direnv = {
        enableZshIntegration = true;
        enable = true;
        nix-direnv.enable = true;
      };

      programs.gh.enable = true;

      home.packages =
        with pkgs;
        [
          yaak
          geany
          kdePackages.dolphin
          devenv
          nodejs_22
          pnpm
          wl-clipboard
          flatpak
          deadbeef
          tilix
          ueberzugpp
          cliphist
          brightnessctl
          poweralertd
          libreoffice-qt6-fresh
          steam-run
          gamemode
          mangohud
          (callPackage inputs.creamlinux-installer { })
        ]
        ++ (with unstable-pkgs; [
          heroic
        ]);

      home.file.".config/hypr" = {
        source = ../../home_modules/external-config/hypr;
        recursive = true;
      };
      home.file.".config/waybar" = {
        source = ../../home_modules/external-config/waybar;
        recursive = true;
      };

      services.ssh-agent.enable = true;
      services.lorri.enable = true;

      systemd.user.startServices = "sd-switch";
    };
in
{
  flake.modules.homeManager.linuxDesktop = linuxDesktop;
  flake.homeModules.linuxDesktop = linuxDesktop;
}
