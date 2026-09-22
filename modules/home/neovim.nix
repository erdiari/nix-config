{ ... }:
let
  neovim =
    { unstable-pkgs, ... }:
    {
      home.packages = [ unstable-pkgs.neovim ];

      home.file.".config/nvim" = {
        source = ../../home_modules/external-config/nvim;
        recursive = true;
      };
    };
in
{
  flake.modules.homeManager.neovim = neovim;
  flake.homeModules.neovim = neovim;
}
