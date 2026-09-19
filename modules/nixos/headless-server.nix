{ ... }:
let
  headlessServer =
    { pkgs, ... }:
    {
      services.tailscale = {
        enable = true;
        openFirewall = true;
        extraUpFlags = [ "--ssh" ];
      };

      networking.firewall.trustedInterfaces = [ "tailscale0" ];

      services.udev.extraRules = ''
        ACTION=="add", SUBSYSTEM=="net", KERNEL!="lo", ATTR{type}=="1", RUN+="${pkgs.ethtool}/bin/ethtool -s $name wol g"
      '';
    };
in
{
  flake.modules.nixos.headlessServer = headlessServer;
  flake.nixosModules.headlessServer = headlessServer;
}
