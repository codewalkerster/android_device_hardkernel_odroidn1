#!/bin/bash

CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
ROOT_DIR=$(pwd)

echo 'build u-boot'
pushd u-boot
make odroidn1_defconfig
make -j$CPU_JOB_NUM
popd

echo 'build kernel'
pushd kernel
make -j$CPU_JOB_NUM odroidn1_defconfig
make -j$CPU_JOB_NUM rk3399-odroidn1-rev0.img
echo 'build kernel module'
make -j$CPU_JOB_NUM
popd

MODULES_DIR=out/target/product/odroidn1/system/lib/modules

echo 'cp ko files'
mkdir -p $MODULES_DIR
find hardware/wifi kernel -name *.ko | xargs -i cp {} $MODULES_DIR

echo 'build android'
source build/envsetup.sh
lunch odroidn1-eng
make -j8

echo 'cp sd_fusing.sh'
cp u-boot/sd_fuse/* rockdev/Image-odroidn1/
