{ ... }:
let
  git =
    { pkgs, ... }:
    {
      programs.git = {
        enable = true;
        lfs.enable = true;
        settings.user = {
          name = "Erdi ARI";
          email = "me@erdiari.dev";
        };
      };

      home.packages = with pkgs; [
        gitui
        lazygit
      ];
    };
in
{
  flake.modules.homeManager.git = git;
  flake.homeModules.git = git;
}
