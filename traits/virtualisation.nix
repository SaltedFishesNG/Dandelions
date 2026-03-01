{ mkBool, ... }:
{
  schema.virtualisation = {
    useLibvirt = mkBool false;
    useXen = mkBool false;
    useVbox = mkBool false;
    useLxc = mkBool false;
  };

  traits.virtualisation =
    {
      lib,
      pkgs,
      schema,
      ...
    }:
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
          dom0Resources.memory = 10000;
        };
        virtualbox.host.enable = cfg.useVbox;
        lxc = {
          enable = cfg.useLxc;
          unprivilegedContainers = true;
        };
      };

      users.users.${schema.base.userName}.extraGroups = [
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
          uris = [
            "qemu:///session"
          ]
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

      # https://github.com/NixOS/nixpkgs/issues/491434
      boot.kernelPackages = lib.mkIf cfg.useVbox pkgs.linuxPackages;
    };
}
