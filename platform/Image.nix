{ lib, modulesPath, ... }:
{
  nixpkgs.hostPlatform = "aarch64-linux";

  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  services.kmscon.enable = lib.mkForce false;
  xdg = {
    autostart.enable = false;
    icons.enable = false;
    menus.enable = false;
    mime.enable = false;
    sounds.enable = false;
  };
}
