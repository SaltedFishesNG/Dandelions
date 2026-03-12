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
        hostname = "iso";
        username = "nixos";
        useSudo-rs = true;
      };
      font.extra = false;
      software.extra = false;
    };
  };
}
