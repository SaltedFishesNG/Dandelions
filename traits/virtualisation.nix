{ mkBool, ... }:
{
  schema.virtualisation = {
    useXen = mkBool false;
    useLxc = mkBool false;
  };

  traits = [
    {
      name = "virtualisation";
      module =
        {
          config,
          lib,
          pkgs,
          schema,
          ...
        }:
        let
          cfg = schema.virtualisation;
          userName = schema.base.userName;
        in
        {
          virtualisation = {
            spiceUSBRedirection.enable = true;
            libvirtd = {
              enable = true;
              qemu = {
                swtpm.enable = true;
                vhostUserPackages = [ pkgs.virtiofsd ];
              };
              onShutdown = "shutdown";
            };
            xen = {
              # /nix/store/*-xen-*/libexec/xen/bin/qemu-system-i386 => /run/current-system/sw/bin/qemu-system-i386
              enable = cfg.useXen;
              dom0Resources.memory = 10000;
            };
            lxc.enable = cfg.useLxc;
          };

          users.users.${userName}.extraGroups = [
            "kvm"
            "libvirtd"
          ];

          environment.systemPackages = [ pkgs.virglrenderer ];
          programs.virt-manager.enable = true;

          networking.firewall.trustedInterfaces = lib.mkIf config.networking.nftables.enable [ "virbr0" ];
        };
    }
  ];
}
