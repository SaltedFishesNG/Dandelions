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
      "extra/disko"
      "extra/lanzaboote"
      "extra/preservation"
      "font"
      "network"
      "software"
      "software/fcitx5"
      "software/game"
      "software/hack"
      "software/proxy"
      "unfree"
      "virtualisation"
    ];

    schema = {
      base = {
        username = "saya";
        password = "none";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObSiBahejD/fe1MOfbrW1XF29t/4yRAPcwphHEFVqET main@saltedfishes.com"
        ];
      };
      extra.disko = {
        device = "/dev/null";
        withLUKS = true;
        useZFS = false;
        espSize = "1000M";
        swapfileSize = "16G";
      };
      network = {
        hostname = "Gamma";
        machineId = "0b88e9f6";
      };
      font.extra = true;
      software.extra = true;
      virtualisation = {
        useLibvirt = true;
        useXen = false;
      };
    };
  };
}
