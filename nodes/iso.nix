{
  nodes.iso = {
    includes = [
      ../platform/iso.nix
      ../resource
    ];

    traits = [
      "base"
      "desktop"
      "font"
      "proxy"
      "software"
    ];

    schema = {
      base = {
        hostName = "iso";
        userName = "nixos";
        useSudo-rs = true;
      };
      font.extra = false;
      software.extra = false;
    };
  };
}
