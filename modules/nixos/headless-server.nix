{ ... }:
let
  headlessServer =
    { ... }:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      networking.firewall.trustedInterfaces = [ "tailscale0" ];
    };
in
{
  flake.modules.nixos.headlessServer = headlessServer;
  flake.nixosModules.headlessServer = headlessServer;
}
