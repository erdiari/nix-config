{ inputs, pkgs, unstable-pkgs, ... }: {
  imports = [
    ./noctalia.nix
  ];

  home = {
    username = "erd";
    homeDirectory = "/home/erd";
  };

  programs.direnv = {
    enableZshIntegration = true;
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs;
    [
      yaak
      geany
      kdePackages.dolphin
      devenv
      grim
      slurp
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
    ] ++ (with unstable-pkgs;
      [
        heroic
        logseq
      ]);

  programs.zsh.shellAliases = {
    install-homemanager =
      "home-manager switch --flake ~/Documents/nix-config#erd";
  };

  services.ssh-agent.enable = true;
  services.lorri.enable = true;

  systemd.user.startServices = "sd-switch";
}
