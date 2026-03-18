{
  lib,
  pkgs,
  username,
  ...
}:
let
  useNetworkManager = true;
in
rec {
  time.timeZone = "UTC";
  i18n.defaultLocale = "C.UTF-8";
  console.keyMap = "us";

  boot = {
    kernelParams = [ "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1" ];
    supportedFilesystems = [ "zfs" ];
    zfs.forceImportRoot = false;
    binfmt.emulatedSystems = builtins.filter (s: s != pkgs.stdenv.hostPlatform.system) [
      "aarch64-linux"
      "riscv64-linux"
      "x86_64-linux"
    ];
    plymouth.enable = false;
    initrd.systemd.enable = true;
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.systemd-boot.configurationLimit = 15;
    loader.efi.canTouchEfiVariables = true;
  };
  system.nixos-init.enable = true;
  system.etc.overlay.enable = true;

  networking = {
    hostName = "NixOS";
    hostId = "00000000";
    dhcpcd.enable = false;
    resolvconf.enable = false;
    networkmanager.enable = useNetworkManager;
    networkmanager.wifi.backend = "iwd";
    wireless.iwd.enable = true;
    nftables.enable = true;
    useNetworkd = (!useNetworkManager);
    useDHCP = (!useNetworkManager);
  };
  systemd.network.enable = (!useNetworkManager);
  services.resolved.enable = false;
  environment.etc."resolv.conf".text = ''
    nameserver 1.1.1.1
    nameserver 2606:4700:4700::1111
    nameserver 8.8.8.8
    nameserver 2001:4860:4860::8888
  '';

  users.mutableUsers = false;
  users.users.${username} = {
    password = "";
    isNormalUser = true;
    extraGroups = [
      "audio"
      "video"
      "wheel"
    ];
    shell = pkgs.fish;
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = "set fish_color_command blue";
  };

  security = {
    rtkit.enable = true;
    sudo.enable = false;
    sudo-rs = {
      enable = true;
      execWheelOnly = true;
      wheelNeedsPassword = false;
    };
    # tpm2 = {
    #   enable = true;
    #   pkcs11.enable = true;
    #   tctiEnvironment.enable = true;
    # };
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Experimental = true;
  };

  services = {
    # logind.settings.Login = {
    #   HandlePowerKey = "hibernate";
    #   HandleLidSwitch = "suspend-then-hibernate";
    # };
    openssh = {
      enable = true;
      ports = [ 22 ];
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = lib.mkForce "prohibit-password";
      };
    };
    kmscon = {
      enable = true;
      extraOptions = "--term xterm-256color";
    };
    zram-generator = {
      enable = true;
      settings.zram0 = {
        compression-algorithm = "zstd";
        zram-size = "ram";
      };
    };
    userborn.enable = true;
    dbus.implementation = "broker";
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  documentation.nixos.enable = false;
  documentation.man.cache.enable = false; # Slow build due to fish enabling caches

  nix = {
    package = pkgs.nixVersions.latest;
    channel.enable = false;
    settings = {
      allowed-users = [ "root" ] ++ nix.settings.trusted-users;
      auto-allocate-uids = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "flakes"
        "nix-command"
        "pipe-operators"
      ];
      pure-eval = true;
      trusted-users = [
        "${username}"
        "@wheel"
      ];
      use-cgroups = true;
      warn-dirty = false;
    };
  };

  system.stateVersion = "26.05";
}
