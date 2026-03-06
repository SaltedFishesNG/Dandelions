{
  nodes.Image = {
    includes = [ ../platform/Image.nix ];

    traits = [
      "base"
      "disko"
      "software"
    ];

    schema = {
      base = {
        hostName = "Image";
        userName = "saya";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObSiBahejD/fe1MOfbrW1XF29t/4yRAPcwphHEFVqET main@saltedfishes.com"
        ];
        useSudo-rs = true;
        useWireless = false;
        useTPM2 = false;
        useBluetooth = false;
        useAudio = false;
      };
      disko = {
        device = "/dev/null";
        withLUKS = false;
        espSize = "100M";
        imageSize = "3G";
      };
      software.extra = false;
    };
  };
}
