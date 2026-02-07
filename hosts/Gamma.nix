{
  hosts.Gamma = {
    system = "x86_64-linux";
    extraModules = [
      ../resource/resource.nix
      ../platform/inspiron-5577.nix
    ];

    basic = {
      enable = true;
      hostName = "Gamma";
      userName = "saya";
      password = "none";
      bootLoaderTimeout = 2;
      font.enable = true;
    };

    desktop = {
      enable = true;
      fcitx5.enable = true;
    };

    extra = {
      disko = {
        enable = true;
        swapfileSize = "16G";
      };
      lanzaboote.enable = true;
      nixvim.enable = true;
      preservation.enable = true;
    };

    software = {
      enable = true;
      game.enable = true;
      hack.enable = true;
      proxy.enable = true;
      virtualisation.enable = true;
    };

    UNFREE.enable = true;
  };
}
