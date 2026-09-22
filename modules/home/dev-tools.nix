{ inputs, ... }:
let
  devTools =
    { pkgs, unstable-pkgs, ... }:
    let
      ompConfig = (pkgs.formats.yaml { }).generate "omp-config.yml" {
        startup.quiet = true;
      };
    in
    {
      # omp itself is installed by Homebrew (see modules/darwin/homebrew.nix);
      # only its config is managed here. omp rewrites this file at runtime and
      # locks it first, so it must be a writable copy, not a store symlink.
      home.activation.ompConfig = {
        before = [ ];
        after = [ "writeBoundary" ];
        data = ''
          run mkdir -p "$HOME/.omp/agent"
          run install -m 600 ${ompConfig} "$HOME/.omp/agent/config.yml"
        '';
      };

      home.packages =
        with pkgs;
        [
          unstable-pkgs.claude-code
          unstable-pkgs.pi-coding-agent
          inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default
          unstable-pkgs.python3
          cargo
          lazydocker
          nil
          nixfmt
          ruff
          rustc
          shellcheck
          shfmt
          uv
        ];
    };
in
{
  flake.modules.homeManager.devTools = devTools;
  flake.homeModules.devTools = devTools;
}
