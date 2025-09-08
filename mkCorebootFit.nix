{
  pkgs,
  board,
  fit-image,
  ...
}:
pkgs.stdenv.mkDerivation (finalAttrs: {
  name = "${finalAttrs.pname}-${finalAttrs.version}";
  pname = "coreboot-${pkgs.lib.toLower board}";
  version = "25.06-unstable-2025-09-07";
  src = pkgs.fetchgit {
    url = "https://github.com/coreboot/coreboot.git";
    rev = "ef1d48ee1d618a94ac5800760dd0a147c0aa951b";
    hash = "sha256-XInuY9JoATvliL2loPF460TPqDU0Btg05oXheccTxIc=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = with pkgs; [
    cacert
    coreboot-toolchain.aarch64
    coreboot-toolchain.arm
    coreutils
    pkg-config
    openssh
    openssl
    python3
  ];

  configurePhase = ''
    cat <<EOF > .config
    CONFIG_VENDOR_GOOGLE=y
    CONFIG_BOARD_GOOGLE_${pkgs.lib.toUpper board}=y
    CONFIG_PAYLOAD_NONE=n
    CONFIG_PAYLOAD_FIT=y
    CONFIG_PAYLOAD_FILE="${fit-image}/uImage"
    CONFIG_PAYLOAD_FIT_SUPPORT=y
    CONFIG_CONSOLE_SERIAL=n
    CONFIG_NO_POST=y
    CONFIG_VPD=y
    EOF
    make olddefconfig
  '';

  buildPhase = ''
    patchShebangs .
    make -j$NIX_BUILD_CORES
  '';

  installPhase = ''
    mkdir $out
    cp .config "$out/${board}.config"
    cp build/coreboot.rom $out/${finalAttrs.name}.rom
  '';
})
