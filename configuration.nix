{
  lib,
  pkgs,
  userName,
  ...
}:
let
  useNetworkManager = true;
in
{
  time.timeZone = "UTC";
  i18n.defaultLocale = "C.UTF-8";
  console.keyMap = "us";

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    binfmt.emulatedSystems = builtins.filter (s: s != pkgs.stdenv.hostPlatform.system) [
      "aarch64-linux"
      "riscv64-linux"
      "x86_64-linux"
    ];
    tmp.cleanOnBoot = true;
    plymouth.enable = false;
    initrd.systemd.enable = true;
    loader.timeout = 2;
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.systemd-boot.configurationLimit = 25;
    loader.efi.canTouchEfiVariables = true;
  };
  system.nixos-init.enable = true;
  system.etc.overlay.enable = true;

  networking = {
    hostName = "NixOS";
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
  users.users.${userName} = {
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
    shellInit = "set fish_color_command blue";
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

  systemd.enableEmergencyMode = false;
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
      trusted-users = [ "${userName}" ];
      experimental-features = [
        "auto-allocate-uids"
        "ca-derivations"
        "cgroups"
        "flakes"
        "nix-command"
        "no-url-literals"
        "pipe-operators"
      ];
      auto-allocate-uids = true;
      auto-optimise-store = true;
      builders-use-substitutes = true;
      pure-eval = true;
      use-cgroups = true;
    };
  };

  system.stateVersion = "26.05";
}
