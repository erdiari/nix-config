{ inputs, ... }:
let
  stylix =
    { ... }:
    {
      imports = [ inputs.stylix.homeModules.stylix ];
    };
in
{
  flake.modules.homeManager.stylix = stylix;
  flake.homeModules.stylix = stylix;
}
