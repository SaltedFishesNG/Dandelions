{
  schema.virtualisation = {
    useLibvirt = false; # bool
    useLxc = false; # bool
    usePodman = false; # bool
    useXen = false; # bool
    xenDom0Memory = 10000; # ints.unsigned
    xenDom0MaxMemory = 10000; # ints.unsigned
  };

  traits.virtualisation =
    {
      config,
      lib,
      node,
      pkgs,
      ...
    }:
    let
      cfg = node.schema.virtualisation;
    in
    {
      environment.systemPackages = with pkgs; [
        OVMFFull.fd
        qemu
        virglrenderer
        virt-manager
        virt-viewer
        virtiofsd
      ];

      virtualisation = {
        containers.enable = true;
        containers.registries.settings = {
          unqualified-search-registries = [
            "quay.io"
            "docker.io"
          ];
          registry = [
            { location = "quay.io"; }
            { location = "docker.io"; }
          ];
        };

        libvirtd = lib.mkIf cfg.useLibvirt {
          enable = true;
          qemu = {
            swtpm.enable = true;
            vhostUserPackages = [ pkgs.virtiofsd ];
          };
          onShutdown = "shutdown";
        };

        lxc = lib.mkIf cfg.useLxc {
          enable = true;
          unprivilegedContainers = true;
        };

        podman = lib.mkIf cfg.usePodman {
          enable = true;
          dockerCompat = true;
          dockerSocket.enable = true;
        };

        xen = lib.mkIf cfg.useXen {
          enable = true;
          dom0Resources.memory = cfg.xenDom0Memory;
          dom0Resources.maxMemory = cfg.xenDom0MaxMemory;
        };
      };

      users.users.${node.schema.base.username}.extraGroups = [
        "kvm"
      ]
      ++ lib.optionals config.virtualisation.libvirtd.enable [ "libvirtd" ]
      ++ lib.optionals config.virtualisation.virtualbox.host.enable [ "vboxusers" ]
      ++ lib.optionals config.virtualisation.lxc.enable [ "lxc-user" ];

      programs.dconf.profiles.user.databases =
        let
          uris =
            lib.optionals (!config.virtualisation.libvirtd.enable) [ "qemu:///session" ]
            ++ lib.optionals config.virtualisation.libvirtd.enable [ "qemu:///system" ]
            ++ lib.optionals config.virtualisation.xen.enable [ "xen:///" ]
            ++ lib.optionals config.virtualisation.lxc.enable [ "lxc:///" ];
        in
        [
          {
            settings."org/virt-manager/virt-manager/connections".autoconnect = uris;
            settings."org/virt-manager/virt-manager/connections".uris = uris;
          }
        ];

      networking.firewall.trustedInterfaces = lib.mkIf config.virtualisation.libvirtd.enable [ "virbr*" ];
    };
}
