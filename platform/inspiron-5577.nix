# https://www.dell.com/support/product-details/en-us/product/inspiron-15-5577-gaming-laptop/overview
{ modulesPath, pkgs, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = [
      "ahci"
      "rtsx_usb_sdmmc"
      "sd_mod"
      "xhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
  };

  hardware.cpu.intel.updateMicrocode = true;
  hardware.nvidia = {
    branch = "legacy_580";
    nvidiaSettings = false;
    open = false;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
      offload.enable = true;
    };
  };
  nixpkgs.config.allowUnfreePackages = [
    "nvidia-x11"
    "nvidia-kernel-modules"
  ];

  services = {
    thermald.enable = true;
    tlp.enable = true;
    xserver.videoDrivers = [ "nvidia" ];
  };
}
