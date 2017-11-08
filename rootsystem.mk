#
# Copyright (C) 2015 Hardkernel Co,. Ltd.
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
RAMDISK_RECOVERY_MKIMG := $(PRODUCT_OUT)/ramdisk-recovery_mkimg.img

.PHONY: $(PRODUCT_OUT)/rootsystem/fstab.$(TARGET_PRODUCT)
$(PRODUCT_OUT)/rootsystem/fstab.$(TARGET_PRODUCT): $(PRODUCT_OUT)/rootsystem
	sed -i "`grep -nE '/system.ext4' $@ | cut -d : -f 1` s/ro /rw /" $@
	sed -i "`grep -nE '/system.ext4' $@.sdboot | cut -d : -f 1` s/ro /rw /" $@.sdboot

.PHONY: $(PRODUCT_OUT)/rootsystem
$(PRODUCT_OUT)/rootsystem: droidcore
	echo combine the directories system/ and root/ into rootsystem/.
	rm -rf $@ && mkdir -p $@
	cp -arp $(PRODUCT_OUT)/root/* $@
	rm -rf $@/etc
	rm -rf $@/vendor
	cp -arp $(PRODUCT_OUT)/system/* $@
	cp -d $(PRODUCT_OUT)/utilities/busybox/bin/* $@/xbin/
	mv $(PRODUCT_OUT)/rootsystem/init $(PRODUCT_OUT)/rootsystem/bin/
	mv $(PRODUCT_OUT)/rootsystem/sbin/healthd $(PRODUCT_OUT)/rootsystem/bin/
	mv $(PRODUCT_OUT)/rootsystem/sbin/adbd $(PRODUCT_OUT)/rootsystem/bin/
	ln -sf /bin/init $(PRODUCT_OUT)/rootsystem/init
	ln -sf /bin/healthd $(PRODUCT_OUT)/rootsystem/sbin/healthd
	ln -sf /bin/adbd $(PRODUCT_OUT)/rootsystem/sbin/adbd
	sed -i "s,^ro.secure=*,ro.secure=0,g" $(PRODUCT_OUT)/rootsystem/default.prop
	u-boot/tools/mkimage -A arm64 -O linux -T ramdisk -a 0x4000000 -e 0x4000000 -n "ramdisk" -d $(PRODUCT_OUT)/ramdisk-recovery.img $(PRODUCT_OUT)/ramdisk-recovery_mkimg.img

$(PRODUCT_OUT)/rootsystem.img: $(PRODUCT_OUT)/rootsystem \
	$(PRODUCT_OUT)/rootsystem/fstab.$(TARGET_PRODUCT)
	echo Creating Android single root file system.
	$(MAKE_EXT4FS) -s -l $(BOARD_SYSTEMIMAGE_PARTITION_SIZE) \
		-L rootsystem -a system $@ $<

.PHONY: rootsystem
rootsystem: $(PRODUCT_OUT)/rootsystem.img
