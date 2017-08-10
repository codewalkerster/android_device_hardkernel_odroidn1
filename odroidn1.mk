#
# Copyright 2017 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This file is the build configuration for an aosp Android
# build for hardkernel odroidn1 hardware. This cleanly combines a set of
# device-specific aspects (drivers) with a device-agnostic
# product configuration (apps). Except for a few implementation
# details, it only fundamentally contains two inherit-product
# lines, aosp and odroidn1, hence its name.


#
# Copyright 2014 The Android Open-Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

$(call inherit-product, $(LOCAL_PATH)/rk3399_64.mk)

PRODUCT_NAME := odroidn1
PRODUCT_DEVICE := odroidn1
PRODUCT_BRAND := ODROID
PRODUCT_MODEL := ODROIDN1
PRODUCT_MANUFACTURER := HardKernel Co., Ltd.

BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_LINUX := true

# Disable bluetooth because of continuous driver crashes
PRODUCT_DEFAULT_PROPERTY_OVERRIDES += config.disable_bluetooth=false

PRODUCT_AAPT_CONFIG := normal large mdpi tvdpi hdpi xhdpi
PRODUCT_AAPT_PREF_CONFIG := hdpi

PRODUCT_SYSTEM_VERITY := true

# debug-logs
ifneq ($(TARGET_BUILD_VARIANT),user)
MIXIN_DEBUG_LOGS := true
endif

# google apps
BUILD_WITH_GOOGLE_MARKET := false
BUILD_WITH_GOOGLE_MARKET_ALL := false
BUILD_WITH_GOOGLE_FRP := false

#for data encrypt options
BUILD_WITH_FORCEENCRYPT := true

#for GMS Certification
BUILD_WITH_GMS_CER := false

#for drm widevine
BUILD_WITH_WIDEVINE := true

#for cts requirement
ifeq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.adb.secure=1 \
    persist.sys.usb.config=mtp
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.adb.secure=0 \
    persist.sys.usb.config=mtp,adb
endif

BOOT_SHUTDOWN_ANIMATION_RINGING := false

BOARD_NFC_SUPPORT := false

BOARD_PROXIMITY_SENSOR_SUPPORT := false
BOARD_PRESSURE_SENSOR_SUPPORT := false
BOARD_TEMPERATURE_SENSOR_SUPPORT := false
BOARD_USB_HOST_SUPPORT := true
PRODUCT_HAS_CAMERA := true
TARGET_ROCKCHIP_PCBATEST := false

PRODUCT_COPY_FILES += \
   device/hardkernel/odroidn1/rk3399_64/ddr_config.xml:system/etc/ddr_config.xml \
   device/hardkernel/odroidn1/rk3399_64/video_status:system/etc/video_status

PRODUCT_PACKAGES += \
    SoundRecorder

# Prebuilt app
PRODUCT_PACKAGES += \
    androidterm

# USB GPS
PRODUCT_PACKAGES += \
    gps.$(PRODUCT_DEVICE)
