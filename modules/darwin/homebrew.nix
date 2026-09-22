{ ... }:
{
  # Homebrew aspect: packages whose upstream ships prebuilt macOS binaries and
  # whose Nix builds are expensive to reproduce (omp bundles its whole Bun
  # dependency closure from source).
  flake.darwinModules.homebrew =
    { ... }:
    {
      homebrew = {
        enable = true;

        taps = [ "can1357/tap" ];

        brews = [ "omp" ];

        onActivation = {
          autoUpdate = true;
          upgrade = true;
          cleanup = "none";
        };
      };
    };
}
