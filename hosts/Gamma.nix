{
  nodes.Gamma = {
    includes = [
      # ../hardware/foo.nix
      ../hardware/inspiron-5577.nix
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
      "unfree"
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
