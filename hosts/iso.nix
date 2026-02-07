{
  hosts.iso = {
    system = "x86_64-linux";
    extraModules = [
      ../resource/resource.nix
      ../platform/iso.nix
    ];

    basic = {
      enable = true;
      hostName = "iso";
      userName = "nixos";
      useSudo-rs = true;
      useSleep = false;
      font.enable = true;
      font.extra = false;
    };

    desktop = {
      enable = true;
      fcitx5.enable = false;
    };

    software = {
      enable = true;
      extra = false;
      game.enable = false;
      hack.enable = false;
      proxy.enable = true;
      virtualisation.enable = false;
    };

    UNFREE.enable = false;
  };
}
