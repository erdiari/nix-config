{ self, inputs, ... }:
let
  mkHome =
    system: modules:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = {
        inherit inputs;
        unstable-pkgs = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      inherit modules;
    };

  # Profile facts: who the user is and where their flake lives.
  user = username: homeDirectory: flakeRef: {
    home.username = username;
    home.homeDirectory = homeDirectory;
    programs.zsh.shellAliases.install-homemanager = "home-manager switch --flake ${flakeRef}";
  };

  cli = with self.homeModules; [
    base
    shell
    git
    yazi
    neovim
    devTools
  ];

  graphical =
    cli
    ++ (with self.homeModules; [
      desktop
      documents
      media
      stylix
    ]);
in
{
  flake.homeConfigurations."erd" = mkHome "x86_64-linux" (
    graphical
    ++ [
      self.homeModules.linuxDesktop
      (user "erd" "/home/erd" "~/Documents/nix-config#erd")
    ]
  );

  flake.homeConfigurations."server" = mkHome "x86_64-linux" (
    cli ++ [ (user "erd" "/home/erd" "github:erdiari/nix-config/main#server") ]
  );

  flake.homeConfigurations."mac-personal" = mkHome "aarch64-darwin" (
    graphical
    ++ [
      self.homeModules.darwinApps
      self.homeModules.ssh
      (user "erd" "/Users/erd" "~/Projects/nix-config#mac-personal")
    ]
  );
}
