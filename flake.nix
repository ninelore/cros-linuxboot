{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    u-root = {
      url = "github:u-root/u-root";
      flake = false;
    };
  };

  outputs =
    inputs@{ self, ... }:
    let
      forSystems = inputs.nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
      ];
    in
    {
      packages = forSystems (
        system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
        rec {
          initramfs-arm64 = import ./mkCpio.nix {
            arch = "aarch64-linux";
            inherit pkgs;
            inherit (inputs) u-root;
          };
          kernel-mtk = import ./mkKernel.nix {
            configfile = ./mediatek_defconfig;
            pkgs = import inputs.nixpkgs {
              localSystem = system;
              crossSystem = "aarch64-linux";
            };
          };
          fit-mtk = import ./mkFit.nix {
            inherit pkgs;
            kernel = kernel-mtk;
            initramfs = initramfs-arm64;
          };
        }
        //
          pkgs.lib.genAttrs'
            [
              # MT8183
              "krane"
              "jacuzzy"
              # MT8186
              "steelix"
              "tentacruel"
              # MT8192
              "hayato"
              # MT8195
              "tomato"
            ]
            (
              board:
              pkgs.lib.nameValuePair ("coreboot-" + board) (
                import ./mkCorebootFit.nix {
                  inherit board pkgs;
                  fit-image = self.packages.${system}.fit-mtk;
                }
              )
            )
      );
    };
}
