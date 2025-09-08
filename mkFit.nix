{
  pkgs,
  kernel,
  initramfs,
  ...
}:
pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fit-mtk";
  inherit (kernel) version;
  src = ./.;
  nativeBuildInputs = with pkgs; [
    dtc
    ubootTools
    xz
  ];
  dontBuild = true;
  installPhase = ''
    mkdir $out
    cp ${kernel}/Image $out/
    cp ${initramfs} $out/initramfs-arm64.cpio
    lzma $out/Image
    lzma $out/initramfs-arm64.cpio
    bash generate-mtk-fit.sh $out ${kernel}/dtbs $out/initramfs-arm64.cpio.lzma
    cp generated-mtk.its $out/
    mkimage -f generated-mtk.its $out/uImage
    # rm -rf $out/Image.lzma $out/initramfs-arm64.cpio.lzma
  '';
})
