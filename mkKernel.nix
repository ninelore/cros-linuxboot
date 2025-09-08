{
  pkgs,
  configfile,
  ...
}:
pkgs.linuxManualConfig {
  inherit (pkgs.linux_latest) version src;
  inherit configfile;
  allowImportFromDerivation = true;
}
