{
  config,
  lib,
  modulesPath,
  ...
}:
{
  nixpkgs.hostPlatform = "aarch64-linux";

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  boot.initrd = {
    postDeviceCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
      # Set the system time from the hardware clock to work around a
      # bug in qemu-kvm > 1.5.2 (where the VM clock is initialised
      # to the *boot time* of the host).
      hwclock -s
    '';
    availableKernelModules = [
      "virtio_net"
      "virtio_pci"
      "virtio_mmio"
      "virtio_blk"
      "virtio_scsi"
    ];
    kernelModules = [
      "virtio_balloon"
      "virtio_console"
      "virtio_rng"
    ];
  };

  services.kmscon.enable = lib.mkForce false;
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}
