#!/usr/bin/env bash

# dt files without extension
devices=(
	'mediatek/mt8183-kukui-jacuzzi-juniper-sku16'
	'mediatek/mt8183-kukui-krane-sku0'
	'mediatek/mt8183-kukui-krane-sku176'
	'mediatek/mt8186-corsola-magneton-sku393216'
	'mediatek/mt8186-corsola-magneton-sku393217'
	'mediatek/mt8186-corsola-magneton-sku393218'
	'mediatek/mt8186-corsola-steelix-sku131072'
	'mediatek/mt8186-corsola-steelix-sku131073'
	'mediatek/mt8186-corsola-tentacool-sku327681'
	'mediatek/mt8186-corsola-tentacool-sku327683'
	'mediatek/mt8186-corsola-tentacruel-sku262144'
	'mediatek/mt8186-corsola-tentacruel-sku262148'
	'mediatek/mt8192-asurada-hayato-r1'
	'mediatek/mt8195-cherry-tomato-r2'
	'mediatek/mt8195-cherry-tomato-r3'
)

kernel_dir="${1:-arch/arm64/boot}"
dtbs_dir="${2:-$kernel_dir/dts}"
initramfs="${3:-/tmp/initramfs.linux_arm64.cpio.lzma}"

cat <<EOF > generated-mtk.its
/dts-v1/;

/ {
    description = "Linux payload";
    #address-cells = <1>;

    images {
        kernel {
            description = "Linux kernel";
            data = /incbin/("$kernel_dir/Image.lzma");
            type = "kernel";
            arch = "arm64";
            os = "linux";
            compression = "lzma";
            load = <0x80000>;
            entry = <0x80000>;
            hash-1 {
                algo = "crc32";
            };
        };
        ramdisk {
            description = "u-root initramfs arm64";
            data = /incbin/("$initramfs");
            type = "ramdisk";
            arch = "arm64";
            os = "linux";
            compression = "none";
            load = <00000000>;
            entry = <00000000>;
            hash-1 {
                algo = "sha1";
            };
        };
EOF

for d in "${devices[@]}"; do
cat <<EOF >> generated-mtk.its
        fdt-$(echo "$d" | sed s/\\//-/) {
            description = "Flattened Device Tree blob";
            data = /incbin/("$dtbs_dir/$d.dtb");
            type = "flat_dt";
            arch = "arm64";
            compression = "none";
            hash-1 {
                algo = "crc32";
            };
        };
EOF
done

cat <<EOF >> generated-mtk.its
    };

    configurations {
EOF

for d in "${devices[@]}"; do
cat <<EOF >> generated-mtk.its
        conf-$(echo "$d" | sed s/\\//-/) {
            description = "Boot Linux kernel with FDT blob";
            cmdline = "console=tty0";
            kernel = "kernel";
            ramdisk = "ramdisk";
            fdt = "fdt-$(echo "$d" | sed s/\\//-/)";
        };
EOF
done

cat <<EOF >> generated-mtk.its
    };
};
EOF

# compatible = "$(dtc -I dtb -O dts "$dtbs_dir/$d.dtb" | sed -n '/^\s*\/\s*{/,/^\s*};/s/^\s*compatible\s*=\s*"\([^"]*\)".*$/\1/p')";
