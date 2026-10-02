{ ... }:
let
  # Fixed transport port so the router stays reachable across restarts
  # (i2pd otherwise picks a random one on first start).
  routerPort = 26880;
in
{
  services.i2pd = {
    enable = true;
    settings = {
      port = routerPort;
      # The LAN has global IPv6; it bypasses the IPv4 NAT, so inbound peers
      # can reach the router without a port forward (if the ISP router's
      # IPv6 firewall allows it).
      ipv6 = true;
      bandwidth = "2048KBps";

      # Web console (7070), HTTP proxy (4444), SOCKS proxy (4447) listen on all
      # interfaces but are only reachable over tailscale0 (trusted); these
      # ports are not opened on the LAN firewall.
      http = {
        address = "0.0.0.0";
        # Default Host-header check only accepts "localhost"; the console is
        # reached via the tailnet hostname instead.
        strictheaders = false;
      };
      httpproxy.address = "0.0.0.0";
      socksproxy.address = "0.0.0.0";
    };
  };

  networking.firewall = {
    allowedTCPPorts = [ routerPort ];
    allowedUDPPorts = [ routerPort ];
  };
}
