{ ... }:
let
  darwinApps =
    { unstable-pkgs, ... }:
    {
      # Homebrew-installed binaries (omp lives here; see
      # modules/darwin/homebrew.nix) are not on PATH by default.
      home.sessionPath = [ "/opt/homebrew/bin" ];

      home.packages = with unstable-pkgs; [
        maccy
        tailscale
      ];
    };
in
{
  flake.modules.homeManager.darwinApps = darwinApps;
  flake.homeModules.darwinApps = darwinApps;
}
