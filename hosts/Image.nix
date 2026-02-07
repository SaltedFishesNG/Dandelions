{
  hosts.Image = {
    system = "x86_64-linux";
    extraModules = [ ../platform/Image.nix ];

    basic = {
      enable = true;
      hostName = "Image";
      userName = "saya";
      password = "";
      useSudo-rs = true;
      useWireless = false;
      useTPM2 = false;
      useBluetooth = false;
      useSleep = false;
      useAudio = false;
      font.enable = false;
    };

    desktop.enable = false;

    extra = {
      disko = {
        enable = true;
        device = "/dev/vda";
        wichLUKS = false;
        ESPsize = "100M";
        imageSize = "2G";
      };
      lanzaboote.enable = false;
      nixvim.enable = false;
      preservation.enable = false;
    };

    software = {
      enable = true;
      extra = false;
      game.enable = false;
      hack.enable = false;
      proxy.enable = false;
      virtualisation.enable = false;
    };

    UNFREE.enable = false;
  };
}
