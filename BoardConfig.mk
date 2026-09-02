#
# Copyright (C) 2025 The Android Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#

# Building with minimal manifest
ALLOW_MISSING_DEPENDENCIES                      := true
BUILD_BROKEN_DUP_RULES                          := true
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES    := true

BUILD_BROKEN_NINJA_USES_ENV_VARS    += RTIC_MPGEN
BUILD_BROKEN_PLUGIN_VALIDATION      := soong-libaosprecovery_defaults soong-libguitwrp_defaults soong-libminuitwrp_defaults soong-vold_defaults

# Architecture
TARGET_ARCH                 := arm64
TARGET_ARCH_VARIANT         := armv8-a
TARGET_CPU_ABI              := arm64-v8a
TARGET_CPU_VARIANT          := oryon

# A/B
AB_OTA_PARTITIONS := \
    boot \
    dataext \
    dtbo \
    init_boot \
    odm \
    recovery \
    system_dlkm \
    vbmeta \
    vendor \
    vendor_boot \
    vendor_dlkm

# Bootloader
PRODUCT_PLATFORM                := kaanapali
TARGET_BOOTLOADER_BOARD_NAME    := Kaanapali

# Crypto
BOARD_USES_METADATA_PARTITION   := true
BOARD_USES_QCOM_FBE_DECRYPTION  := true
TW_INCLUDE_CRYPTO               := true
TW_INCLUDE_CRYPTO_FBE           := true
TW_INCLUDE_FBE_METADATA_DECRYPT := true
TW_USE_FSCRYPT_POLICY           := 2
#TW_INCLUDE_OMAPI                := true
#TW_OMAPI_UUID                   := 636F6D2E6E78702E7365637572697479 

# Debug
TARGET_USES_LOGD                := true
TWRP_INCLUDE_LOGCAT             := true
TARGET_RECOVERY_DEVICE_MODULES  += debuggerd
TARGET_RECOVERY_DEVICE_MODULES  += strace
RECOVERY_BINARY_SOURCE_FILES    += $(TARGET_OUT_EXECUTABLES)/debuggerd
RECOVERY_BINARY_SOURCE_FILES    += $(TARGET_OUT_EXECUTABLES)/strace

# File systems
TARGET_USERIMAGES_USE_EXT4  := true
TARGET_USERIMAGES_USE_F2FS  := true
TW_USE_DMCTL               := true

# Init
#TARGET_INIT_VENDOR_LIB          := //$(DEVICE_PATH):libinit_oplus_sm87xx
#TARGET_RECOVERY_DEVICE_MODULES  := libinit_oplus_sm87xx

# Kernel
BOARD_KERNEL_IMAGE_NAME     := Image
BOARD_BOOT_HEADER_VERSION   := 4
BOARD_KERNEL_PAGESIZE       := 4096
BOARD_MKBOOTIMG_ARGS        += --header_version $(BOARD_BOOT_HEADER_VERSION)
BOARD_MKBOOTIMG_ARGS        += --pagesize $(BOARD_KERNEL_PAGESIZE)

BOARD_RAMDISK_USE_LZ4       := true

# Partitions
BOARD_PROPERTY_OVERRIDES_SPLIT_ENABLED  := true
BOARD_RECOVERYIMAGE_PARTITION_SIZE      := 104857600

BOARD_SUPER_PARTITION_SIZE := 21474836480
BOARD_SUPER_PARTITION_GROUPS := qti_dynamic_partitions
BOARD_QTI_DYNAMIC_PARTITIONS_PARTITION_LIST := system odm product system_ext vendor vendor_dlkm
BOARD_QTI_DYNAMIC_PARTITIONS_SIZE := 21470642176

BOARD_ODMIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_ODM             := odm
TARGET_COPY_OUT_VENDOR          := vendor

# Platform
TARGET_BOARD_PLATFORM   := sm8850
QCOM_BOARD_PLATFORMS    += sm8850

# Recovery
BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE    := true
TARGET_RECOVERY_PIXEL_FORMAT                := RGBX_8888
TW_INCLUDE_FASTBOOTD                        := true

# Tool
TW_ENABLE_ALL_PARTITION_TOOLS := true
TW_INCLUDE_7ZA                := true
TW_INCLUDE_REPACKTOOLS        := true
TW_INCLUDE_RESETPROP          := true
TW_USE_TOOLBOX                := true

# TWRP display
TW_BRIGHTNESS_PATH      := /sys/class/backlight/panel0-backlight/brightness
TW_DEFAULT_BRIGHTNESS   := 2000
TW_FRAMERATE            := 60
TW_MAX_BRIGHTNESS       := 4095
TW_SCREEN_BLANK_ON_BOOT := true
ifeq ($(USE_LANDSCAPE),true)
	RECOVERY_TOUCHSCREEN_FLIP_Y := true
	RECOVERY_TOUCHSCREEN_SWAP_XY := true
	TW_THEME := landscape_hdpi
	TW_ROTATION := 90
else
	RECOVERY_TOUCHSCREEN_FLIP_Y := false
	RECOVERY_TOUCHSCREEN_SWAP_XY := false
	TW_THEME := portrait_hdpi
	TW_ROTATION := 0
endif

# TWRP file system
RECOVERY_SDCARD_ON_DATA     := true
TARGET_USES_MKE2FS          := true
TW_ENABLE_FS_COMPRESSION    := true
TW_INCLUDE_FUSE_NTFS        := true
TW_INCLUDE_NTFS_3G          := true
TW_NO_EXFAT_FUSE            := true

# Version
PLATFORM_VERSION                := 99.87.36
PLATFORM_VERSION_LAST_STABLE    := $(PLATFORM_VERSION)
PLATFORM_SECURITY_PATCH         := 2099-12-31
VENDOR_SECURITY_PATCH           := $(PLATFORM_SECURITY_PATCH)
ifeq ($(TW_DEVICE_VERSION),)
TW_DEVICE_VERSION               := TB323FU
endif

# Verified Boot
BOARD_AVB_ENABLE := true

# Vibrator
TW_SUPPORT_INPUT_AIDL_HAPTICS := true

# Other TWRP Configurations
TARGET_RECOVERY_QCOM_RTC_FIX            := true
TW_DEFAULT_LANGUAGE                     := en
TW_EXCLUDE_APEX                         := true
TW_EXCLUDE_DEFAULT_USB_INIT             := true
TW_EXTRA_LANGUAGES                      := true
TW_LOAD_VENDOR_MODULES                  := "adsp_loader_dlkm.ko stm_st54se_gpio.ko nxp-nci.ko spcom.ko spss_utils.ko"
TW_LOAD_VENDOR_MODULES_EXCLUDE_GKI      := true
TW_USE_SERIALNO_PROPERTY_FOR_DEVICE_ID  := true
TW_NO_NETWORK                           := true
TW_HAS_EDL_MODE                         := true
TW_SKIP_ADDITIONAL_FSTAB                := true
TW_INPUT_BLACKLIST                      := "hbtp_vm"

# TB323FU Android 16 recovery crypto fallback:
# AIDL KeyMint V4 is the real service; force a non-empty legacy TWRP helper
# property so old Keymaster-version detection cannot reset it to blank.
TW_FORCE_KEYMASTER_VER := true
