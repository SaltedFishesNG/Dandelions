{ lib, mkOpt, ... }:
{
  schema.base = {
    useLix = mkOpt lib.types.bool false;
    nixSubstituters = mkOpt (lib.types.listOf lib.types.str) [ ];

    hostname = mkOpt lib.types.str "NixOS";
    machineId = mkOpt lib.types.str "00000000";
    username = mkOpt lib.types.str "alice";
    password = mkOpt (lib.types.nullOr lib.types.str) null;
    hashedPassword = mkOpt (lib.types.nullOr lib.types.str) null;
    authorizedKeys = mkOpt (lib.types.listOf lib.types.singleLineStr) [ ];

    useSudo-rs = mkOpt lib.types.bool false;
    useWireless = mkOpt lib.types.bool true;
    useNetworkManager = mkOpt lib.types.bool true;
    useTPM2 = mkOpt lib.types.bool true;
    useBluetooth = mkOpt lib.types.bool true;
    useAudio = mkOpt lib.types.bool true;
  };

  traits.base =
    { pkgs, schema, ... }:
    let
      cfg = schema.base;
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
        loader.systemd-boot.configurationLimit = 25;
        loader.efi.canTouchEfiVariables = true;
      };
      system.nixos-init.enable = true;
      system.etc.overlay.enable = true;

      networking = {
        hostName = lib.mkDefault cfg.hostname;
        hostId = cfg.machineId;
        nftables.enable = true;
        dhcpcd.enable = false;
        resolvconf.enable = false;
        networkmanager.enable = cfg.useNetworkManager;
        networkmanager.wifi.backend = lib.mkIf cfg.useWireless "iwd";
        wireless.iwd.enable = cfg.useWireless;
        useNetworkd = !cfg.useNetworkManager;
        useDHCP = !cfg.useNetworkManager;
      };
      systemd.network.enable = !cfg.useNetworkManager;
      services.resolved.enable = false;
      environment.etc."resolv.conf".text = ''
        nameserver 1.1.1.1
        nameserver 2606:4700:4700::1111
        nameserver 8.8.8.8
        nameserver 2001:4860:4860::8888
      '';

      users.mutableUsers = false;
      users.users.${cfg.username} = {
        password = if (cfg.hashedPassword != null || cfg.password != null) then cfg.password else "";
        hashedPassword = cfg.hashedPassword;
        openssh.authorizedKeys.keys = cfg.authorizedKeys;
        isNormalUser = true;
        extraGroups = [
          "audio"
          "input"
          "video"
          "wheel"
        ];
        shell = pkgs.fish;
      };
      programs.fish = {
        enable = true;
        shellAbbrs = {
          sudo = lib.mkIf (!cfg.useSudo-rs) "doas";
        };
        interactiveShellInit = "set fish_color_command blue";
      };

      security = {
        doas = {
          enable = true;
          extraConfig = "permit persist keepenv :wheel";
        };
        rtkit.enable = true;
        sudo.enable = false;
        sudo-rs = {
          enable = cfg.useSudo-rs;
          execWheelOnly = true;
          wheelNeedsPassword = false;
        };
        tpm2 = {
          enable = cfg.useTPM2;
          pkcs11.enable = true;
          tctiEnvironment.enable = true;
        };
      };

      hardware.bluetooth = {
        enable = cfg.useBluetooth;
        powerOnBoot = true;
        settings.General.Experimental = true;
      };

      services = {
        logind.settings.Login = {
          HandlePowerKey = "hibernate";
          HandleLidSwitch = "suspend-then-hibernate";
        };
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
          enable = cfg.useAudio;
          alsa.enable = true;
          pulse.enable = true;
        };
      };

      documentation.nixos.enable = false;
      documentation.man.cache.enable = false; # Slow build due to fish enabling caches

      nix = {
        package = if cfg.useLix then pkgs.lixPackageSets.stable.lix else pkgs.nixVersions.latest;
        channel.enable = false;
        settings = {
          allowed-users = [ "root" ] ++ nix.settings.trusted-users;
          auto-allocate-uids = true;
          auto-optimise-store = true;
          builders-use-substitutes = true;
          experimental-features = [
            "auto-allocate-uids"
            "cgroups"
            "flakes"
            "nix-command"
          ]
          ++ lib.optionals cfg.useLix [ "pipe-operator" ]
          ++ lib.optionals (!cfg.useLix) [
            "ca-derivations"
            "pipe-operators"
          ];
          pure-eval = true;
          substituters = cfg.nixSubstituters;
          trusted-users = [
            "${cfg.username}"
            "@wheel"
          ];
          use-cgroups = true;
          warn-dirty = false;
        };
      };

      system.stateVersion = lib.mkDefault "26.05";
    };
}
