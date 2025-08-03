{ inputs, lib, config, pkgs, unstable-pkgs, ... }: {

  imports = [ ./default.nix ];

  home = {
    username = "erd";
    homeDirectory = "/Users/erd";
  };

  home.packages = with unstable-pkgs; [
    maccy
 ];

  # macOS-specific git configuration
  programs.git = {
    userName = "Erdi ARI";
    userEmail = "me@erdiari.dev"; 
  };

  # macOS-specific shell aliases
  programs.zsh.shellAliases = {
    install-homemanager = "home-manager switch --flake ~/Projects/nix-config#erd";
  };
}
