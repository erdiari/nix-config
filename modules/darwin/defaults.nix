{ ... }: {
  flake.darwinModules.darwinDefaults = { inputs, lib, config, pkgs, unstable-pkgs, ... }: {
    system.stateVersion = 5;

    nix = {
      enable = true;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        # Admin users may use the flake's extra-substituters; without this the
        # daemon ignores them for non-root callers (e.g. `home-manager switch`)
        # and every uncached path builds from source.
        trusted-users = [ "@admin" ];
      };
      optimise = {
        automatic = true;
      };
      gc = {
        automatic = true;
        interval = { Weekday = 0; Hour = 2; Minute = 0; };
        options = "--delete-older-than 30d";
      };
    };

    environment.systemPackages = with pkgs; [
      neovim
      git
      curl
      wget
    ];

    fonts.packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];

  };
}
