{ modulesPath, pkgs, ... }:
{
  system.stateVersion = "26.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "sd_mod"
      "rtsx_usb_sdmmc"
    ];
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "kvm-intel" ];
  };
  hardware.cpu.intel.updateMicrocode = true;
}
