#!/bin/sh
PKGDIR=out/target/product/odroidn1/updatepackage

if [ -d ./updatepackage.base ]; then
	diff -srq $PKGDIR/ ./updatepackage.base/ | grep identical | awk -F ' ' '{print $2}' | xargs rm -rf
fi
