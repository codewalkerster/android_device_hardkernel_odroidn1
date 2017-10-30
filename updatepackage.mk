SIGNJAR := out/host/linux-x86/framework/signapk.jar

PKGDIR=$(PRODUCT_OUT)/updatepackage

UBOOT := u-boot/sd_fuse
KERNEL := kernel
IMAGES := rockdev/Image-odroidn1

$(PRODUCT_OUT)/updatepackage.zip: rootsystem recovery
	rm -rf $@
	rm -rf $(PKGDIR)
	mkdir -p $(PKGDIR)/META-INF/com/google/android
	cp -a $(UBOOT)/idbloader.img $(PKGDIR)
	cp -a $(UBOOT)/uboot.img $(PKGDIR)
	cp -a $(UBOOT)/trust.img $(PKGDIR)
	cp -a $(KERNEL)/resource.img $(PKGDIR)
	cp -a $(KERNEL)/kernel.img $(PKGDIR)
	cp -a $(PRODUCT_OUT)/rootsystem $(PKGDIR)
	find $(PKGDIR)/rootsystem -type l | xargs rm -rf
	cp -a $(PRODUCT_OUT)/ramdisk-recovery_mkimg.img $(PKGDIR)
#	mkdir $(PKGDIR)/system/etc -p
#	cp -a $(PRODUCT_OUT)/system/etc/boot.ini.template $(PKGDIR)/system/etc/
	cp -a $(PRODUCT_OUT)/system/bin/updater \
		$(PKGDIR)/META-INF/com/google/android/update-binary
	cp -a $(TARGET_DEVICE_DIR)/recovery/updater-script.updatepackage \
		$(PKGDIR)/META-INF/com/google/android/updater-script
	( pushd $(PKGDIR); \
		zip -r $(CURDIR)/$@ * ; \
	)

$(PRODUCT_OUT)/updatepackage-$(TARGET_DEVICE)-signed.zip: \
	$(PRODUCT_OUT)/updatepackage.zip
	java \
		-Djava.library.path=out/host/linux-x86/lib64 \
		-jar $(SIGNJAR) \
		-w $(DEFAULT_KEY_CERT_PAIR).x509.pem \
		$(DEFAULT_KEY_CERT_PAIR).pk8 $< $@

.PHONY: updatepackage
updatepackage: $(PRODUCT_OUT)/updatepackage-$(TARGET_DEVICE)-signed.zip
