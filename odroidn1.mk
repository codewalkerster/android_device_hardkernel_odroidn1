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

include device/hardkernel/odroidn1/BoardConfig.mk
# Inherit from those products. Most specific first.
$(call inherit-product, device/hardkernel/odroidn1/product.mk)
$(call inherit-product, device/hardkernel/common/device.mk)
$(call inherit-product, device/hardkernel/proprietary/proprietary.mk)

PRODUCT_CHARACTERISTICS := tablet
PRODUCT_SHIPPING_API_LEVEL :=25

# Live Wallpapers
PRODUCT_PACKAGES += \
        rild \
        Launcher3

PRODUCT_NAME := odroidn1
PRODUCT_DEVICE := odroidn1
PRODUCT_BRAND := ODROID
PRODUCT_MODEL := ODROIDN1
PRODUCT_MANUFACTURER := HardKernel Co., Ltd.

# USB GPS
PRODUCT_PACKAGES += \
    gps.$(PRODUCT_DEVICE)

# Get the long list of APNs
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/apns-full-conf.xml:system/etc/apns-conf.xml
PRODUCT_COPY_FILES += vendor/rockchip/common/phone/etc/spn-conf.xml:system/etc/spn-conf.xml
