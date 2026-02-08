{
  nodes.iso = {
    meta.system = "x86_64-linux";

    includes = [
      ../platform/iso.nix
      ../resource/resource.nix
    ];

    traits = [
      "base"
      "font"
      "desktop"
      "software"
      "proxy"
    ];

    schema = {
      base = {
        hostName = "iso";
        userName = "nixos";
        useSudo-rs = true;
        useSleep = false;
      };
      font.extra = false;
      software.extra = false;
    };
  };
}
