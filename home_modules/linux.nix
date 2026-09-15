{
  inputs,
  pkgs,
  unstable-pkgs,
  ...
}:
{
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

  programs.zsh.shellAliases = {
    install-homemanager = "home-manager switch --flake ~/Documents/nix-config#erd";
  };

  services.ssh-agent.enable = true;
  services.lorri.enable = true;

  systemd.user.startServices = "sd-switch";
}
