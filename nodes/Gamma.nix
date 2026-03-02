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
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObSiBahejD/fe1MOfbrW1XF29t/4yRAPcwphHEFVqET main@saltedfishes.com"
        ];
        bootLoaderTimeout = 2;
      };
      disko = {
        device = "/dev/sda";
        espSize = "1000M";
        swapfileSize = "16G";
        withLUKS = true;
      };
      font.extra = true;
      software.extra = true;
      virtualisation.useLibvirt = true;
    };
  };
}
