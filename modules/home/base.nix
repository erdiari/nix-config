{ ... }:
let
  base =
    { ... }:
    {
      nixpkgs = {
        overlays = [ ];
        config = {
          allowUnfree = true;
          allowUnfreePredicate = _: true;
        };
      };

      programs.home-manager.enable = true;

      home.sessionPath = [ "$HOME/.local/bin" ];

      home.stateVersion = "23.05";
    };
in
{
  flake.modules.homeManager.base = base;
  flake.homeModules.base = base;
}
