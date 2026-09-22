{ ... }:
let
  documents =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        pandoc
        tectonic
        typst
      ];
    };
in
{
  flake.modules.homeManager.documents = documents;
  flake.homeModules.documents = documents;
}
