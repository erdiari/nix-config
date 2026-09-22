{ ... }:
let
  ssh =
    { ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;

        settings."*" = {
          # Private keys live only in the Bitwarden vault; the desktop app
          # serves them over this socket (.dmg / Homebrew-cask path; Mac App
          # Store builds are sandboxed under ~/Library/Containers instead).
          # IdentityAgent rather than SSH_AUTH_SOCK, so GUI clients that never
          # source the shell profile are covered too.
          identityAgent = "~/.bitwarden-ssh-agent.sock";
        };
      };
    };
in
{
  flake.modules.homeManager.ssh = ssh;
  flake.homeModules.ssh = ssh;
}
