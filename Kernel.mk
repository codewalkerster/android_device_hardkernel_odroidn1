#if use probuilt kernel or build kernel from source code

INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel

KERNEL_ARCH := arm64
KERNEL_DEFCONFIG := odroidn1_defconfig
PREFIX_CROSS_COMPILE := aarch64-linux-android-
UBOOT_CROSS_COMPILE := aarch64-linux-gnu-

KERNEL_ROOTDIR := kernel
KERNEL_CONFIG := $(KERNEL_ROOTDIR)/.config
KERNEL_IMAGE := $(KERNEL_ROOTDIR)/arch/$(KERNEL_ARCH)/boot/Image
KERNEL_MODULES_INSTALL := system
KERNEL_MODULES_OUT := $(TARGET_OUT)/lib/modules

$(KERNEL_MODULES_OUT):
	mkdir -p $(KERNEL_MODULES_OUT)

$(KERNEL_CONFIG):
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEFCONFIG)

$(KERNEL_IMAGE): $(KERNEL_CONFIG) $(KERNEL_MODULES_OUT)
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) rk3399-odroidn1-rev0.img modules
	find $(KERNEL_ROOTDIR)/../hardware/wifi -name *.ko | xargs -i cp {} $(PRODUCT_OUT)/system/lib/modules
	find $(KERNEL_ROOTDIR) -name *.ko | xargs -i cp {} $(PRODUCT_OUT)/system/lib/modules

UBOOT_ARCHV := aarch64
UBOOT_DEFCONFIG := odroidn1_defconfig
UBOOT_ROOTDIR := u-boot
UBOOT_IMAGE := $(UBOOT_ROOTDIR)/sd_fuse/u-boot.bin
UBOOT_CONFIG := $(UBOOT_ROOTDIR)/.config

$(UBOOT_CONFIG):
	$(MAKE) -C $(UBOOT_ROOTDIR) ARCHV=$(UBOOT_ARCHV) \
		CROSS_COMPILE=$(UBOOT_CROSS_COMPILE) $(UBOOT_DEFCONFIG)

$(UBOOT_IMAGE): $(UBOOT_CONFIG)
	$(MAKE) -C $(UBOOT_ROOTDIR) ARCHV=$(UBOOT_ARCHV) \
		CROSS_COMPILE=$(UBOOT_CROSS_COMPILE)
	@pushd $(UBOOT_ROOTDIR) && \
	tools/rk_tools/bin/loaderimage --pack --uboot u-boot-dtb.bin uboot.img && \
	tools/mkimage -n rk3399 -T rksd -d tools/rk_tools/bin/rk33/rk3399_ddr_800MHz_v1.08.bin idbloader.img && \
	cat tools/rk_tools/bin/rk33/rk3399_miniloader_v1.06.bin >> idbloader.img && \
	cp tools/rk_tools/bin/rk33/rk3399_loader_v1.08.106.bin sd_fuse && \
	tools/rk_tools/bin/trust_merger tools/rk_tools/trust.ini && \
	cp idbloader.img sd_fuse && \
	cp uboot.img sd_fuse && \
	cp trust.img sd_fuse && \
	popd

$(INSTALLED_KERNEL_TARGET): $(KERNEL_IMAGE) $(UBOOT_IMAGE) | $(ACP)
	@echo "Kernel installed"
	@echo "U-boot installed"
	$(transform-prebuilt-to-target)
