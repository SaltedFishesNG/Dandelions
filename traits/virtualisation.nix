{
  schema.virtualisation = {
    useLibvirt = false; # bool
    useXen = false; # bool
    xenDom0Memory = 10000; # ints.unsigned
    xenDom0MaxMemory = 10000; # ints.unsigned
    useVbox = false; # bool
    useLxc = false; # bool
  };

  traits.virtualisation =
    {
      lib,
      node,
      pkgs,
      ...
    }:
    let
      cfg = node.schema.virtualisation;
    in
    {
      virtualisation = {
        libvirtd = {
          enable = cfg.useLibvirt;
          qemu = {
            swtpm.enable = true;
            vhostUserPackages = [ pkgs.virtiofsd ];
          };
          onShutdown = "shutdown";
        };
        xen = {
          enable = cfg.useXen;
          dom0Resources.memory = cfg.xenDom0Memory;
          dom0Resources.maxMemory = cfg.xenDom0MaxMemory;
        };
        virtualbox.host.enable = cfg.useVbox;
        lxc = {
          enable = cfg.useLxc;
          unprivilegedContainers = true;
        };
      };

      users.users.${node.schema.base.username}.extraGroups = [
        "kvm"
      ]
      ++ lib.optionals cfg.useLibvirt [ "libvirtd" ]
      ++ lib.optionals cfg.useVbox [ "vboxusers" ]
      ++ lib.optionals cfg.useLxc [ "lxc-user" ];

      environment.systemPackages = with pkgs; [
        qemu
        virglrenderer
        virt-manager
        virt-viewer
        virtiofsd
      ];

      programs.dconf.profiles.user.databases =
        let
          uris =
            [ ]
            ++ lib.optionals (!cfg.useLibvirt) [ "qemu:///session" ]
            ++ lib.optionals cfg.useLibvirt [ "qemu:///system" ]
            ++ lib.optionals cfg.useXen [ "xen:///" ]
            ++ lib.optionals (cfg.useLxc && cfg.useLibvirt) [ "lxc:///" ];
        in
        [
          {
            settings."org/virt-manager/virt-manager/connections".autoconnect = uris;
            settings."org/virt-manager/virt-manager/connections".uris = uris;
          }
        ];

      networking.firewall.trustedInterfaces = lib.mkIf cfg.useLibvirt [ "virbr*" ];
    };
}
