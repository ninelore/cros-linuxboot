{
  pkgs,
  configfile,
  ...
}:
pkgs.linuxManualConfig rec {
  version = "6.16.4";
  src = pkgs.fetchurl {
    url = "mirror://kernel/linux/kernel/v${pkgs.lib.versions.major version}.x/linux-${version}.tar.xz";
    hash = "sha256-1qXjxxoQtTOnViUTh8yL9Iu9XHbYQrpelX2LHDFqtiI=";
  };
  inherit configfile;
  allowImportFromDerivation = true;
}
