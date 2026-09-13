{
  schema.network = {
    hostname = "NixOS"; # str
    machineId = "00000000"; # str
    networkmanager.enable = true; # bool
    wireless.enable = true; # bool
  };

  traits.network =
    {
      config,
      lib,
      node,
      ...
    }:
    let
      cfg = node.schema.network // config.networking.firewall;
    in
    {
      networking = {
        hostName = lib.mkDefault cfg.hostname;
        hostId = cfg.machineId;
        dhcpcd.enable = false;
        networkmanager.enable = cfg.networkmanager.enable;
        networkmanager.wifi.backend = lib.mkIf cfg.wireless.enable "iwd";
        wireless.iwd.enable = cfg.wireless.enable;
        useNetworkd = !cfg.networkmanager.enable;
        useDHCP = !cfg.networkmanager.enable;
      };
      systemd.network.enable = !cfg.networkmanager.enable;

      networking.resolvconf.enable = false;
      services.resolved.enable = false;
      environment.etc."resolv.conf".text = ''
        nameserver 1.1.1.1
        nameserver 2606:4700:4700::1111
        nameserver 8.8.8.8
        nameserver 2001:4860:4860::8888
      '';

      networking.firewall.enable = false;
      networking.nftables.enable = true;
      networking.nftables.ruleset =
        let
          ifaceSet = lib.concatStringsSep ", " (map (x: ''"${x}"'') cfg.trustedInterfaces);
          portsToNftSet =
            ports: portRanges:
            lib.concatStringsSep ", " (
              map toString ports ++ map (x: "${toString x.from}-${toString x.to}") portRanges
            );
          allow = lib.concatStrings (
            lib.mapAttrsToList (
              iface: cfg:
              let
                ifaceMatch = lib.optionalString (iface != "default") ''iifname "${iface}" '';
                tcpSet = portsToNftSet cfg.allowedTCPPorts cfg.allowedTCPPortRanges;
                udpSet = portsToNftSet cfg.allowedUDPPorts cfg.allowedUDPPortRanges;
              in
              ''
                ${lib.optionalString (tcpSet != "") "${ifaceMatch}tcp dport { ${tcpSet} } accept"}
                ${lib.optionalString (udpSet != "") "${ifaceMatch}udp dport { ${udpSet} } accept"}
              ''
            ) cfg.allInterfaces
          );
        in
        ''
          table inet filter {
            chain input {
              type filter hook input priority filter; policy drop;
              ct state vmap { invalid : drop, established : accept, related : accept }

              iifname "lo" accept
              ${lib.optionalString (ifaceSet != "") "iifname { ${ifaceSet} } accept"}

              icmp type { echo-request, destination-unreachable, time-exceeded } accept
              icmpv6 type != { nd-redirect, 139 } accept

              meta nfproto ipv4 udp sport . udp dport { 68 . 67, 67 . 68 } accept
              ip6 daddr fe80::/64 udp dport 546 accept

              meta nfproto ipv4 fib saddr . mark . iif oif exists accept

              ${allow}
              ${cfg.extraInputRules}
            }

            chain forward {
              type filter hook forward priority filter; policy drop;
              ct state vmap { invalid : drop, established : accept, related : accept }

              ${lib.optionalString (ifaceSet != "") "iifname { ${ifaceSet} } accept"}

              icmpv6 type != { router-renumbering, 139 } accept
              ct status dnat accept
              ${cfg.extraForwardRules}
            }

            chain output {
              type filter hook output priority filter; policy accept;
              oifname "lo" accept
              ct state invalid drop
            }
          }
        '';

      boot.kernelModules = [ "tcp_bbr" ];
      boot.kernel.sysctl = {
        "net.core.default_qdisc" = "cake";
        "net.ipv4.tcp_congestion_control" = "bbr";
      };
    };
}
