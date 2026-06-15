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
      "network"
      "secrets"
      "software"
      "software/proxy"
    ];

    schema = {
      base = {
        username = "nixos";
        useSudo-rs = true;
      };
      font.extra = false;
      network = {
        hostname = "iso";
      };
      software.extra = false;
    };
  };
}
