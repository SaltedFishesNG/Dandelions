{ lib, mkOpt, ... }:
{
  schema.virtualisation = {
    useLibvirt = mkOpt lib.types.bool false;
    useXen = mkOpt lib.types.bool false;
    xenDom0Memory = mkOpt lib.types.ints.unsigned 10000;
    xenDom0MaxMemory = mkOpt lib.types.ints.unsigned 10000;
    useVbox = mkOpt lib.types.bool false;
    useLxc = mkOpt lib.types.bool false;
  };

  traits.virtualisation =
    { pkgs, schema, ... }:
    let
      cfg = schema.virtualisation;
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

      users.users.${schema.base.username}.extraGroups = [
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

      # https://github.com/NixOS/nixpkgs/issues/263359
      # https://github.com/NixOS/nixpkgs/issues/416031
      networking.firewall.interfaces."virbr*" = lib.mkIf cfg.useLibvirt {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [
          53
          67
          547
        ];
      };
    };
}
