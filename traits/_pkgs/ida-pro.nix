# https://cloud.saltedfishes.com/Nix/ida92
# https://cloud.saltedfishes.com/Nix/ida93
# https://od.cloudsploit.top/temp/9.3/ida93

# https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/id/ida-free/package.nix
{
  autoPatchelfHook,
  cairo,
  dbus,
  # requireFile,
  fetchurl,
  fontconfig,
  freetype,
  glib,
  gtk3,
  lib,
  libdrm,
  libGL,
  libkrb5,
  libsecret,
  libunwind,
  libxkbcommon,
  makeWrapper,
  openssl,
  stdenv,
  libxcb-wm,
  libxcb-render-util,
  libxcb-keysyms,
  libxcb-image,
  libxcb-cursor,
  libxrender,
  libxi,
  libxext,
  libxau,
  libx11,
  libsm,
  libice,
  libxcb,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ida-pro";
  version = "9.3";

  srcs = [
    (fetchurl {
      name = "ida-pro_93_x64linux.run";
      url = "https://cloud.saltedfishes.com/api/raw/?path=/Nix/ida93/ida-pro_93_x64linux.run";
      hash = "sha256-LtQ65LuE103K5vAJkhDfqNYb/qSVL1+aB6mq4Wy3D4I=";
    })
    (fetchurl {
      name = "idapro.hexlic";
      url = "https://cloud.saltedfishes.com/api/raw/?path=/Nix/ida93/kg_patch/idapro.hexlic";
      sha256 = "sha256-tgRlRAwfPH28Uud3FHmy7gaBOncPiJK7ymGkarE4jh0=";
    })
    (fetchurl {
      name = "libida.so";
      url = "https://cloud.saltedfishes.com/api/raw/?path=/Nix/ida93/kg_patch/linux/libida.so";
      sha256 = "sha256-frcPbcLVec+qt+DwBvV3/tNTZOZAOU3IbnXU8aNXMl8=";
    })
    (fetchurl {
      name = "libida32.so";
      url = "https://cloud.saltedfishes.com/api/raw/?path=/Nix/ida93/kg_patch/linux/libida32.so";
      sha256 = "sha256-F5hfoaDRv0BOGb3gpQrHEv6rugvqBfCqjAa4wBAwJZY=";
    })
  ];

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  # We just get a runfile in $src, so no need to unpack it.
  dontUnpack = true;

  # Add everything to the RPATH, in case IDA decides to dlopen things.
  runtimeDependencies = [
    cairo
    dbus
    fontconfig
    freetype
    glib
    gtk3
    libdrm
    libGL
    libkrb5
    libsecret
    libunwind
    libxkbcommon
    openssl
    stdenv.cc.cc
    libice
    libsm
    libx11
    libxau
    libxcb
    libxext
    libxi
    libxrender
    libxcb-image
    libxcb-keysyms
    libxcb-render-util
    libxcb-wm
    libxcb-cursor
    zlib
  ];
  buildInputs = finalAttrs.runtimeDependencies;

  # IDA comes with its own Qt6, some dependencies are missing in the installer.
  autoPatchelfIgnoreMissingDeps = [
    "libQt6Network.so.6"
    "libQt6EglFSDeviceIntegration.so.6"
    "libQt6WaylandEglClientHwIntegration.so.6"
    "libQt6WlShellIntegration.so.6"
    "libQt6WaylandCompositor.so.6"
  ];

  installPhase = ''
    runHook preInstall

    # IDA depends on quite some things extracted by the runfile, so first extract everything
    # into $out/opt, then remove the unnecessary files and directories.
    IDADIR=$out/opt/${finalAttrs.pname}-${finalAttrs.version}
    mkdir -p $out/bin $IDADIR

    # The installer doesn't honor `--prefix` in all places,
    # thus needing to set `HOME` here.
    HOME=$out

    # Invoke the installer with the dynamic loader directly, avoiding the need
    # to copy it to fix permissions and patch the executable.
    $(cat $NIX_CC/nix-support/dynamic-linker) ${builtins.elemAt finalAttrs.srcs 0} \
      --mode unattended --prefix $IDADIR
    cp ${builtins.elemAt finalAttrs.srcs 1} $IDADIR/idapro.hexlic
    cp ${builtins.elemAt finalAttrs.srcs 2} $IDADIR/libida.so
    cp ${builtins.elemAt finalAttrs.srcs 3} $IDADIR/libida32.so

    # Some libraries come with the installer.
    addAutoPatchelfSearchPath $IDADIR

    # Wrap the ida executable to set QT_PLUGIN_PATH
    wrapProgram $IDADIR/ida --prefix QT_PLUGIN_PATH : $IDADIR/plugins/platforms
    ln -s $IDADIR/ida $out/bin/ida

    # runtimeDependencies don't get added to non-executables, and openssl is needed
    #  for cloud decompilation
    patchelf --add-needed libcrypto.so $IDADIR/libida.so

    mv $out/.local/share $out
    rm -r $out/.local

    runHook postInstall
  '';

  meta = {
    description = "Freeware version of the world's smartest and most feature-full disassembler";
    homepage = "https://hex-rays.com/";
    changelog = "https://hex-rays.com/products/ida/news/";
    license = lib.licenses.unfree;
    mainProgram = "ida";
    maintainers = with lib.maintainers; [ msanft ];
    platforms = [ "x86_64-linux" ]; # Right now, the installation script only supports Linux.
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
