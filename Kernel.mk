#if use probuilt kernel or build kernel from source code

INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel

KERNEL_ARCH := arm64
KERNEL_DEFCONFIG := odroidn1_defconfig
PREFIX_CROSS_COMPILE := aarch64-linux-gnu-

KERNEL_ROOTDIR := kernel
KERNEL_CONFIG := $(KERNEL_ROOTDIR)/.config
KERNEL_IMAGE := $(KERNEL_ROOTDIR)/arch/$(KERNEL_ARCH)/boot/Image
DTB_IMAGE := $(KERNEL_ROOTDIR)/arch/$(KERNEL_ARCH)/boot/dts/rockchip/rk3399-odroidn1-rev0.dtb
KERNEL_MODULES_INSTALL := system
KERNEL_MODULES_OUT := $(TARGET_OUT)/lib/modules

$(KERNEL_MODULES_OUT):
	mkdir -p $(KERNEL_MODULES_OUT)

$(KERNEL_CONFIG):
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) distclean
	find $(KERNEL_ROOTDIR)/../hardware/wifi -name *.ko | xargs rm -rf
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEFCONFIG)

$(KERNEL_IMAGE): $(KERNEL_CONFIG) $(KERNEL_MODULES_OUT)
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE)
	find $(KERNEL_ROOTDIR)/../hardware/wifi -name *.ko | xargs -i cp {} $(PRODUCT_OUT)/system/lib/modules
	find $(KERNEL_ROOTDIR) -name *.ko | xargs -i cp {} $(PRODUCT_OUT)/system/lib/modules

UBOOT_ARCHV := aarch64
UBOOT_DEFCONFIG := odroidn1_defconfig
UBOOT_ROOTDIR := u-boot
UBOOT_IMAGE := $(UBOOT_ROOTDIR)/u-boot.bin
UBOOT_CONFIG := $(UBOOT_ROOTDIR)/.config

$(UBOOT_CONFIG):
	$(MAKE) -C $(UBOOT_ROOTDIR) ARCHV=$(UBOOT_ARCHV) clean
	$(MAKE) -C $(UBOOT_ROOTDIR) ARCHV=$(UBOOT_ARCHV) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(UBOOT_DEFCONFIG)

$(UBOOT_IMAGE): $(UBOOT_CONFIG)
	$(MAKE) -C $(UBOOT_ROOTDIR) ARCHV=$(UBOOT_ARCHV) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE)

$(INSTALLED_KERNEL_TARGET): $(KERNEL_IMAGE) $(UBOOT_IMAGE) | $(ACP)
	@echo "Kernel installed"
	@echo "U-boot installed"
	$(transform-prebuilt-to-target)
