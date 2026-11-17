# TWRP Recovery device tree for Redmi A5 (serenity) — Android 17

Ported and refreshed for Android 17. Lineage:

- Original port: [KSN2redawew/android_device_xiaomi_serenity-twrp](https://github.com/KSN2redawew/android_device_xiaomi_serenity-twrp)
- Maintained reference tree: `recovery_device_xiaomi_serenity` (device/xiaomi/serenity, Android 15)
- This tree: `output/xiaomi/serenity` — same structure and patches, updated to
  **Global A17.0.4.0.XGWMIXM** (images dated 2026-11-07).

## What changed vs. the A15 tree

- `BOARD_BOOT_HEADER_VERSION` stays `4`; recovery lives inside `vendor_boot` on A17
  (the A17 vendor_boot ramdisk *is* the recovery rootfs —
  `system/bin/recovery`, ELF built for Android 37).
- `recovery/root/system/etc/recovery.fstab` — verbatim from the A17 image
  (`uni_custom` added, `/data` f2fs now uses `fscompress` + `atgc`).
- `recovery/root/first_stage_ramdisk/fstab.serenity` — verbatim from A17.
- `recovery/root/lib/modules/` — A17 kernel modules (154 `.ko`, kernel 6.18),
  incl. `modules.load.recovery`.
- `recovery/root/vendor/` — crypto HAL stack replaced with A17:
  `android.hardware.security.keymint-unisoc.service.trusty` +
  `android.hardware.gatekeeper-service.trusty` (AIDL KeyMint v5/v3,
  "rust.trusty"), AIDL health v5, aggregate VINTF manifest +
  compatibility matrix from stock A17. Reference A15 stack preserved in
  `vendor.bak-a15/`.
- `init.recovery.serenity.rc` — rewritten for A17: advertises Android 17 /
  2026-10-01 patch to KeyMint, starts AIDL boot-control / health / KeyMint /
  Gatekeeper services after hwservicemanager is up, all as `u:r:recovery:s0`
  (the recovery sepolicy does not know the stock HAL domain labels).
  The reference tree's dangling `boot-hal-1-2` / `health-hal-2-1` starts were
  fixed to the actual service names (`vendor.boot-default`,
  `vendor.sprd.boot-aidl-V1-recovery`, `vendor.health-default`).
- `splpath_util_recovery.rc` + `system/bin/splpath_util_recovery` — stock A17
  script copied into the tree (creates `spl_a`/`spl_b` by-name symlinks);
  seclabel switched to `u:r:recovery:s0` (stock `create_spl_link_recovery`
  domain does not exist in the PBRP recovery policy). The reference's
  `create_splloader_dual_slot_byname_path.sh` is now redundant.
- `system/etc/twrp.flags` — `flashimg=1` removed from all verified-boot /
  NV partitions (vbmeta*, uboot, sml, tos, teecfg, modem/DSP, PMNV/NV);
  `/spl` pointed at the real `splloader`/`splloader_bak`; bogus `/hypervisor`
  entry dropped (typo + no such partition).
- `device.mk` — HIDL health@2.x build packages removed (stock AIDL health
  service in the ramdisk is used instead).
- `prebuilt/dtb.img` — raw, uncompressed FDT extracted from `vendor_boot.img`
  (Unisoc ums9230 / SERENITY 6H10). The kitchen's `dtb` was LZ4-legacy and was
  moved to `dtb.img.lz4-legacy` for reference only.
- `prebuilt/kernel` — ARM64 Image extracted from `boot.img` (reference only;
  the build uses `TARGET_NO_KERNEL := true` and does not repack the kernel).
- `VENDOR_SECURITY_PATCH` / `PLATFORM_SECURITY_PATCH` = `2026-10-01`.
- Removed the skeleton's fake `2099-12-31` patch dates and `--flags 3`
  vbmeta arguments. See note below.

## Build it yourself

### 1. Download the TWRP source and device tree

```shell
mkdir -p ~/twrp
cd ~/twrp

repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-12.1
repo sync

git clone /path/to/output/xiaomi/serenity device/xiaomi/serenity
```

All commands below must be run from the Android source root (`~/twrp`),
not from inside `device/xiaomi/serenity`.

### 2. Install the recovery patches

(The device tree contains one replacement source file and three patches; these
were written against the stock **Android 15** KeyMint libraries and have **not
yet been re-audited against Android 17**. Verify them at build time.)

```shell
cd ~/twrp
cp device/xiaomi/serenity/patch/graphics_drm.cpp bootable/recovery/minuitwrp/graphics_drm.cpp
git apply --check device/xiaomi/serenity/patch/libcxx_verbose_abort.patch && git apply device/xiaomi/serenity/patch/libcxx_verbose_abort.patch
git apply --check device/xiaomi/serenity/patch/vold_android15_keyblob.patch && git apply device/xiaomi/serenity/patch/vold_android15_keyblob.patch
git apply --check device/xiaomi/serenity/patch/vold_recovery_fscrypt_keyring.patch && git apply device/xiaomi/serenity/patch/vold_recovery_fscrypt_keyring.patch
```

### 3. Build vendor_boot

```shell
cd ~/twrp
source build/envsetup.sh
lunch twrp_serenity-eng
m vendorbootimage
```

The resulting image is:

```text
out/target/product/serenity/vendor_boot.img
```

Verify before flashing:

```shell
test -s out/target/product/serenity/recovery/root/system/bin/recovery
file out/target/product/serenity/recovery/root/system/bin/recovery
test -f out/target/product/serenity/recovery/root/twres/splash.xml
test -f out/target/product/serenity/recovery/root/twres/ui.xml
```

## To use it

```shell
fastboot getvar current-slot
# If the current slot is a:
fastboot flash vendor_boot_a vendor_boot.img
# If the current slot is b:
fastboot flash vendor_boot_b vendor_boot.img
```

**This only works on a device with the bootloader unlocked (or otherwise able
to boot custom vendor_boot). On a locked, enforcing device the custom image is
rejected by verified boot — the screen will say "The system has been destroyed".**

## Credits

- [KSN2redawew](https://github.com/KSN2redawew) — original serenity TWRP port
- [farrizdesignpro](https://github.com/farrizdesignpro1339) — A15 tree maintenance / reference
- rtyutechstudio, Zyrexen, Chillax, danilaim — original testing & patches

`prebuilt/kernel_dtb` (20 MB) is kept for reference and is not referenced by
the build (`TARGET_NO_KERNEL := true`). `dtb.img.lz4-legacy` is the kitchen's
LZ4-legacy variant of the same FDT, kept in case a future build uses
`--dtb_compression=lz4`.
