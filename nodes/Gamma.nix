{
  nodes.Gamma = {
    includes = [
      # ../platform/foo.nix
      ../platform/inspiron-5577.nix
      ../resource
    ];

    traits = [
      "base"
      "desktop"
      "disko"
      "fcitx5"
      "font"
      "game"
      "hack"
      "lanzaboote"
      "preservation"
      "proxy"
      "software"
      "unfree"
      "virtualisation"
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
