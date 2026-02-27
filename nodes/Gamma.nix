{
  nodes.Gamma = {
    includes = [
      # ../platform/foo.nix
      ../platform/inspiron-5577.nix
      ../resource
    ];

    traits = [
      "base"
      "font"
      "desktop"
      "fcitx5"
      "software"
      "game"
      "hack"
      "proxy"
      "virtualisation"
      "disko"
      "lanzaboote"
      "preservation"
      "UNFREE"
    ];

    schema = {
      base = {
        hostName = "Gamma";
        userName = "saya";
        password = "none";
        bootLoaderTimeout = 2;
      };
      font.extra = true;
      software.extra = true;
      disko = {
        device = "/dev/sda";
        espSize = "1000M";
        swapfileSize = "16G";
        withLUKS = true;
      };
    };
  };
}
