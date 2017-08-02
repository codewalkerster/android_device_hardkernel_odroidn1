#if use probuilt kernel or build kernel from source code

INSTALLED_KERNEL_TARGET := $(PRODUCT_OUT)/kernel

KERNEL_ARCH := arm64
ARCHV=aarch64
KERNEL_DEFCONFIG := odroidn1_defconfig

KERNEL_ROOTDIR := kernel
KERNEL_CONFIG := $(KERNEL_ROOTDIR)/.config
KERNEL_IMAGE := $(KERNEL_ROOTDIR)/arch/$(KERNEL_ARCH)/boot/Image
KERNEL_MODULES_INSTALL := system
KERNEL_MODULES_OUT := $(TARGET_OUT)/lib/modules

PREFIX_CROSS_COMPILE=aarch64-linux-android-

$(KERNEL_MODULES_OUT):
	mkdir -p $(KERNEL_MODULES_OUT)

$(KERNEL_CONFIG):
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) $(KERNEL_DEFCONFIG)

$(KERNEL_IMAGE): $(KERNEL_CONFIG) $(KERNEL_MODULES_OUT)
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE) rk3399-odroidn1-rev0.img
	$(MAKE) -C $(KERNEL_ROOTDIR) ARCH=$(KERNEL_ARCH) \
		CROSS_COMPILE=$(PREFIX_CROSS_COMPILE)
	find $(KERNEL_ROOTDIR)/../hardware/wifi -name *.ko | xargs -i cp {} $(PRODUCT_OUT)/system/lib/modules
	find $(KERNEL_ROOTDIR) -name *.ko | xargs -i cp {} $(PRODUCT_OUT)/system/lib/modules

$(INSTALLED_KERNEL_TARGET): $(KERNEL_IMAGE) | $(ACP)
	@echo "Kernel installed"
	$(transform-prebuilt-to-target)
