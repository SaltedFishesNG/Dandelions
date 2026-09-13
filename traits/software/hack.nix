{
  schema.software.hack = {
    extra = false; # bool
  };

  traits."software/hack" =
    {
      lib,
      node,
      pkgs,
      ...
    }:
    {
      environment.systemPackages =
        with pkgs;
        [
          nmap
          (proxmark3.override { hardwarePlatform = "PM3GENERIC"; })
          wireshark
        ]
        ++ lib.optionals node.schema.software.hack.extra [
          aircrack-ng
          (cutter.withPlugins (ps: with ps; [ jsdec ] ++ [ rz-ghidra ] ++ [ sigdb ]))
          ghidra-bin
          nikto
          nuclei
        ];

      programs.wireshark = {
        enable = true;
        usbmon.enable = true;
        dumpcap.enable = true;
      };

      users.users.${node.schema.base.username}.extraGroups = [ "wireshark" ];
    };
}
