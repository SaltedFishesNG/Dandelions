{ modulesPath, pkgs, ... }:
{
  system.stateVersion = "26.11";
  nixpkgs.hostPlatform = "x86_64-linux";
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
}
