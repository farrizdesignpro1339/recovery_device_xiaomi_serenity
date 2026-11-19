# OrangeFox Recovery device tree — Redmi A5 (serenity) — Android 17

Port of the original serenity TWRP/PBRP recovery tree to the
**OrangeFox 16.0** (`fox_16.0`) build system against Android 17.

Client device: Redmi A5 (serenity_global / serenity), Unisoc T7250 (ums9230),
8 cores (6x Cortex-A55 + 2x Cortex-A75), recovery embedded in `vendor_boot`.

Data verified against the official Global **A17.0.4.0.XGWMIXM** images
(extracted 2026-11-17, `serenity_global-images-A17.0.4.0.XGWMIXM-user-20261107.0000.00-17.0-global-d87e02eb1d`).

## What changed vs. the A15 / TWRP tree

- BoardConfig: `FOX_*` variables live **only** in `vendorsetup.sh` (per OrangeFox docs), not in `.mk` files.
- `FOX_AB_DEVICE=1`, `FOX_VIRTUAL_AB_DEVICE=1`, `FOX_VENDOR_BOOT_RECOVERY=1`
  (recovery is in `vendor_boot` — **experimental** flag, see OrangeFox wiki),
  `FOX_VANILLA_BUILD=1`, `FOX_FORCE_PREBUILT_KERNEL=1`, `FOX_MAINTAINER_PATCH_VERSION=01`.
- Base moved to Android 16: `PLATFORM_VERSION=16.0.0`, VNDK/SHIPPING = 36.
- `recovery/root/vendor/` — A17 stock crypto HAL stack:
  AIDL KeyMint v5/v3 (`rust.trusty`) + AIDL Gatekeeper + AIDL health,
  aggregate VINTF manifest + `compatibility_matrix.xml` from the stock A17.
  The A15 stack is kept in `recovery/root/vendor.bak-a15/`.
- `init.recovery.serenity.rc` — starts AIDL boot-control / health / KeyMint /
  Gatekeeper after `hwservicemanager` is up, all `u:r:recovery:s0`.
  Advertises `ro.build.version.release=17` and `security_patch=2026-10-01`
  so stock KeyMint will open the metadata key.
- fstab / modules / `init.recovery.common.rc` taken from the stock A17 images.
- `twrp.flags`: `flashimg=1` removed from verified-boot / NV partitions.
- `gsi_keys.mk` / `full_base_telephony.mk` removed (not present in A16 build system).

## Building (OrangeFox 16.0 / `fox_16.0`)

```bash
# 1. Sync the OrangeFox 16.0 manifest (NOT TWRP minimal-manifest)
mkdir -p ~/fox_16.0 && cd ~/fox_16.0
repo init --depth=1 -u https://gitlab.com/OrangeFox/Manifest.git -b fox_16.0
repo sync -c -j$(nproc) --no-clone-bundle --no-tags

# 2. Place this device tree
git clone -b fox_16.0 \
  https://github.com/farrizdesignpro1339/recovery_device_xiaomi_serenity.git \
  device/xiaomi/serenity

# 3. Add TW_* build-time overrides (optional): export FOX_BUILD_DEVICE=serenity
#    is already done in vendorsetup.sh (sourced by envsetup)

# 4. Build
source build/envsetup.sh
FOX_BUILD_DEVICE=serenity lunch twrp_serenity-eng
mka vendorbootimage -j$(nproc)
```

For a device with recovery in `vendor_boot`, the output is
`out/target/product/serenity/vendor_boot.img` (not `recovery.img`).
See `wiki.orangefox.tech` → "vendor_boot-as-recovery" caveats:
the zip created by OrangeFox will contain `vendor_ramdisk_recovery.cpio`;
the working flash path is `fastboot flash vendor_boot vendor_ramdisk_recovery.cpio`
(usually via fastbootd), or flash the stock boot tool via FDL/BROM.

## Credits

- Original serenity TWRP/PBRP: [KSN2redawew](https://github.com/KSN2redawew)
- OrangeFox port: farrizdesignpro1339
- Tested against stock Global A15 / A17 images for serenity.

`kernel_dtb` / `dtb.img.lz4-legacy` / `vendor.bak-a15/` are build/reference
artifacts and are git-ignored.
