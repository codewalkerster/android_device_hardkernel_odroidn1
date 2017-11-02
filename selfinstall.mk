#
# Copyright (C) 2017 Hardkernel Co,. Ltd.
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

SIGNJAR := out/host/linux-x86/framework/signapk.jar

KERNEL := kernel
UBOOT := u-boot/sd_fuse
IDBLOADER := $(UBOOT)/idbloader.img

SELFINSTALL_DIR := $(PRODUCT_OUT)/selfinstall
SELFINSTALL_SIGNED_UPDATEPACKAGE := $(SELFINSTALL_DIR)/cache/update.zip
BOOTLOADER_MESSAGE := $(SELFINSTALL_DIR)/BOOTLOADER_MESSAGE
SELFINSTALL_CACHE_IMAGE := $(SELFINSTALL_DIR)/cache.ext4

RAMDISK_RECOVERY_MKIMG := $(PRODUCT_OUT)/ramdisk-recovery_mkimg.img

$(RAMDISK_RECOVERY_MKIMG): recoveryimage $(PRODUCT_OUT)/ramdisk-recovery.img
	u-boot/tools/mkimage -A arm64 -O linux -T ramdisk -a 0x4000000 -e 0x4000000 -n "ramdisk" -d $(PRODUCT_OUT)/ramdisk-recovery.img $(PRODUCT_OUT)/ramdisk-recovery_mkimg.img

#
# Update image : update.zip
#
UPDATE_PACKAGE_PATH := $(SELFINSTALL_DIR)/otapackages

$(SELFINSTALL_DIR)/update.unsigned.zip: cacheimage rootsystem recoveryimage
	rm -rf $@
	rm -rf $(UPDATE_PACKAGE_PATH)
	mkdir -p $(UPDATE_PACKAGE_PATH)/META-INF/com/google/android
	cp -af $(PRODUCT_OUT)/rootsystem.img $(UPDATE_PACKAGE_PATH)
	cp -af $(INSTALLED_CACHEIMAGE_TARGET) $(UPDATE_PACKAGE_PATH)
	cp -af $(PRODUCT_OUT)/system/bin/updater \
		$(UPDATE_PACKAGE_PATH)/META-INF/com/google/android/update-binary
	cp -af $(TARGET_DEVICE_DIR)/recovery/updater-script \
		$(UPDATE_PACKAGE_PATH)/META-INF/com/google/android/updater-script
	( pushd $(UPDATE_PACKAGE_PATH); \
		zip -r $(CURDIR)/$@ * ; \
	)

$(SELFINSTALL_SIGNED_UPDATEPACKAGE): $(SELFINSTALL_DIR)/update.unsigned.zip
	mkdir -p $(dir $@)
	java \
		-Djava.library.path=out/host/linux-x86/lib64 \
		-jar $(SIGNJAR) \
		-w $(DEFAULT_KEY_CERT_PAIR).x509.pem \
		$(DEFAULT_KEY_CERT_PAIR).pk8 $< $@

$(BOOTLOADER_MESSAGE):
	mkdir -p $(dir $@)
	dd if=/dev/zero of=$@ bs=16 count=4	# 64 Bytes
	echo "recovery" >> $@
	echo "--locale=en_US" >> $@
	echo "--selfinstall" >> $@
	echo "--update_package=CACHE:update.zip" >> $@

.PHONY: $(SELFINSTALL_DIR)/cache
$(SELFINSTALL_DIR)/cache: $(SELFINSTALL_SIGNED_UPDATEPACKAGE) $(BOOTLOADER_MESSAGE)
	cp -af $(PRODUCT_OUT)/cache/ $(SELFINSTALL_DIR)/

$(SELFINSTALL_DIR)/cache.img: $(SELFINSTALL_DIR)/cache
	$(MAKE_EXT4FS) -s -L cache -a cache \
		-l $(BOARD_CACHEIMAGE_PARTITION_SIZE) $@ $<

$(SELFINSTALL_CACHE_IMAGE): $(SELFINSTALL_DIR)/cache.img
	simg2img $(SELFINSTALL_DIR)/cache.img $@

#
# Android Self-Installation
#
$(PRODUCT_OUT)/selfinstall-$(TARGET_DEVICE).bin: \
	$(IDBLOADER) \
	$(UBOOT)/uboot.img \
	$(UBOOT)/trust.img \
	$(BOOTLOADER_MESSAGE) \
	$(RAMDISK_RECOVERY_MKIMG) \
	$(KERNEL)/arch/arm64/boot/dts/rockchip/rk3399-odroidn1-rev0.dtb \
	$(KERNEL)/arch/arm64/boot/Image \
	$(SELFINSTALL_CACHE_IMAGE)
	@echo "Creating installable single image file..."
	dd if=$(IDBLOADER) of=$@ conv=fsync bs=512 seek=64
	dd if=$(UBOOT)/uboot.img of=$@ conv=fsync bs=512 seek=16384
	dd if=$(UBOOT)/trust.img of=$@ conv=fsync bs=512 seek=24576
	dd if=$(BOOTLOADER_MESSAGE) of=$@ conv=fsync bs=512 seek=32768
	dd if=$(KERNEL)/arch/arm64/boot/dts/rockchip/rk3399-odroidn1-rev0.dtb of=$@ conv=fsync bs=512 seek=32776
	dd if=$(KERNEL)/arch/arm64/boot/Image of=$@ conv=fsync bs=512 seek=65544
	dd if=$(PRODUCT_OUT)/ramdisk-recovery_mkimg.img of=$@ conv=fsync bs=512 seek=180232
	dd if=$(SELFINSTALL_CACHE_IMAGE) of=$@ bs=512 seek=247808
	sync
	@echo "Done."

.PHONY: selfinstall
selfinstall: $(recovery_ramdisk) $(PRODUCT_OUT)/selfinstall-$(TARGET_DEVICE).bin
