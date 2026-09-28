{ inputs, ... }:
let
  devTools =
    {
      lib,
      pkgs,
      unstable-pkgs,
      ...
    }:
    let
      ompConfig = (pkgs.formats.yaml { }).generate "omp-config.yml" {
        startup.quiet = true;
      };
    in
    {
      imports = [ inputs.omp.homeManagerModules.default ];

      # On Linux omp comes from the omp flake and owns its own config.yml.
      # On darwin Homebrew installs it (see modules/darwin/homebrew.nix) and
      # its config is managed here. omp rewrites this file at runtime and
      # locks it first, so it must be a writable copy, not a store symlink.
      programs.omp.enable = pkgs.stdenv.hostPlatform.isLinux;

      home.activation.ompConfig = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
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
