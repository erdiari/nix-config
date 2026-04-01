{ inputs, unstable-pkgs, ... }: {
  home = {
    username = "erd";
    homeDirectory = "/Users/erd";
  };

  home.packages = with unstable-pkgs; [
    maccy
    tailscale
  ];

  programs.zsh.shellAliases = {
    install-homemanager = "home-manager switch --flake ~/Projects/nix-config#erd";
  };
}
