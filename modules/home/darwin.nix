{ inputs, unstable-pkgs, ... }: {
  imports = [
    inputs.stylix.homeModules.stylix
    ./default.nix
  ];

  home = {
    username = "erd";
    homeDirectory = "/Users/erd";
  };

  home.packages = with unstable-pkgs; [
    maccy
    tailscale
  ];

  programs.git = {
    userName = "Erdi ARI";
    userEmail = "me@erdiari.dev";
  };

  programs.zsh.shellAliases = {
    install-homemanager = "home-manager switch --flake ~/Projects/nix-config#erd";
  };
}
