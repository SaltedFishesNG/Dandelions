{
  nodes.Image = {
    includes = [ ../platform/Image.nix ];

    traits = [
      "base"
      "disko"
      "network"
      "software"
    ];

    schema = {
      base = {
        username = "saya";
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIObSiBahejD/fe1MOfbrW1XF29t/4yRAPcwphHEFVqET main@saltedfishes.com"
        ];
        useSudo-rs = true;
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
      network = {
        hostname = "Image";
        useWireless = false;
      };
      software.extra = false;
    };
  };
}
