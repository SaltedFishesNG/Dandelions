{
  nodes.iso = {
    includes = [
      ../hardware/iso.nix
      ../resource
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
