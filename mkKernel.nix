{
  pkgs,
  configfile,
  ...
}:
pkgs.linuxManualConfig rec {
  version = "6.17.8";
  src = pkgs.fetchurl {
    url = "mirror://kernel/linux/kernel/v${pkgs.lib.versions.major version}.x/linux-${version}.tar.xz";
    hash = "sha256-Wo3mSnX8pwbAHGwKd891p0YYQ52xleJfHwJor2svsdo=";
  };
  inherit configfile;
  allowImportFromDerivation = true;
}
