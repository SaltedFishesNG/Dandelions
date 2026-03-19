{
  traits.lanzaboote =
    { inputs, lib, ... }:
    {
      imports = [ inputs.lanzaboote.nixosModules.lanzaboote ];

      boot.loader = {
        grub.enable = lib.mkForce false;
        limine.enable = lib.mkForce false;
        refind.enable = lib.mkForce false;
        systemd-boot.enable = lib.mkForce false;
      };

      boot.lanzaboote = {
        enable = true;
        pkiBundle = "/persist/var/lib/sbctl";
        autoGenerateKeys.enable = true;
      };
    };
}
