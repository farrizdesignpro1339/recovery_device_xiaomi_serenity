#
# Copyright (C) 2026 The Android Open Source Project
# Copyright (C) 2026 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit some common Omni stuff.
$(call inherit-product, vendor/omni/config/common.mk)

# Inherit from serenity device
$(call inherit-product, device/xiaomi/serenity/device.mk)

PRODUCT_DEVICE := serenity
PRODUCT_NAME := omni_serenity
PRODUCT_BRAND := Redmi
PRODUCT_MODEL := serenity
PRODUCT_MANUFACTURER := xiaomi

PRODUCT_GMS_CLIENTID_BASE := android-xiaomi

PRODUCT_BUILD_PROP_OVERRIDES += \
    PRIVATE_BUILD_DESC="mivnd_others_global-user 17 CP2A.260605.016 A17.0.4.0.XGWMIXM"

BUILD_FINGERPRINT := Redmi/mivnd_others_ums9230_go_64only/mivnd_others_ums9230:17/CP2A.260605.016/A17.0.4.0.XGWMIXM:user/release-keys
