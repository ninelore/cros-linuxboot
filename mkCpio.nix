{
  arch ? pkgs.system,
  pkgs,
  u-root,
  ...
}:
pkgs.stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    goarch =
      {
        "aarch64-linux" = "arm64";
        "x86_64-linux" = "amd64";
      }
      .${arch};
  in
  {
    src = u-root;
    name = "u-root-initramfs-${goarch}";
    nativeBuildInputs = [
      pkgs.go
      pkgs.u-root
    ];
    dontBuild = true;
    installPhase = ''
      export GOOS=linux 
      export GOARCH=${goarch}
      export GOCACHE=$TMPDIR/go-cache
      export GOPATH="$TMPDIR/go"
      ${pkgs.u-root}/bin/u-root \
        -uinitcmd "gosh -c 'sleep 1; boot'" \
        -o $out \
        cmds/core/init \
        cmds/core/gosh \
        cmds/boot/boot
    '';
  }
)
