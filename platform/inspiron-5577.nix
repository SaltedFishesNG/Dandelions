# https://www.dell.com/support/product-details/en-us/product/inspiron-15-5577-gaming-laptop/overview
# https://www.nvidia.com/en-us/drivers/details/261243/
# https://us.download.nvidia.com/XFree86/Linux-x86_64/580.126.09/NVIDIA-Linux-x86_64-580.126.09.run
{ modulesPath, ... }:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot = {
    binfmt.emulatedSystems = [
      "aarch64-linux"
      "riscv64-linux"
    ];
    initrd.availableKernelModules = [
      "ahci"
      "rtsx_usb_sdmmc"
      "sd_mod"
      "xhci_pci"
    ];
    kernelModules = [ "kvm-intel" ];
    blacklistedKernelModules = [ "nouveau" ];
  };

  hardware.cpu.intel.updateMicrocode = true;

  hardware.graphics.enable = true;
  hardware.nvidia = {
    open = false;
    modesetting.enable = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };
  powerManagement.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];
}
