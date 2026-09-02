#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/lenovo/TB323FU

# Inherit from device.mk configuration
$(call inherit-product, $(DEVICE_PATH)/device.mk)

## Device identifier
PRODUCT_DEVICE       := TB323FU
PRODUCT_NAME         := twrp_TB323FU
PRODUCT_BRAND        := Lenovo
PRODUCT_MANUFACTURER := LENOVO
PRODUCT_MODEL        := TB323FU

# Theme
TW_STATUS_ICONS_ALIGN   := center
TW_Y_OFFSET             := 0
TW_H_OFFSET             := 0
