# OrangeFox build variables for Redmi A5 (serenity) - Android 17
# FOX_* variables ONLY live here (shell), not in any .mk file - see OrangeFox docs.

export FOX_BUILD_DEVICE=serenity

# Device is Virtaul A/B (A/B, seamless updates)
export FOX_AB_DEVICE=1
export FOX_VIRTUAL_AB_DEVICE=1

# Recovery is built into vendor_boot (hdr4, Android 13+). Experimental!
export FOX_VENDOR_BOOT_RECOVERY=1

# Plain A/B build - skip MIUI OTA/patching process
export FOX_VANILLA_BUILD=1

# Prebuilt kernel (we do not build the kernel in this tree)
export FOX_FORCE_PREBUILT_KERNEL=1

# Optional versioning/info for the builder
export FOX_MAINTAINER_PATCH_VERSION=01
export FOX_MAINTAINER="FarrizDesignPro"
