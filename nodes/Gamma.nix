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
        useLix = true;
        nixSubstituters = [ "https://mirror.sjtu.edu.cn/nix-channels/store" ];
        hostname = "Gamma";
        machineId = "0b88e9f6";
        userName = "saya";
        password = "none";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObSiBahejD/fe1MOfbrW1XF29t/4yRAPcwphHEFVqET main@saltedfishes.com"
        ];
      };
      disko = {
        device = "/dev/null";
        withLUKS = true;
        useZFS = false;
        espSize = "1000M";
        swapfileSize = "16G";
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
