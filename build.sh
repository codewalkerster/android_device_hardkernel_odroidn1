#!/bin/bash
export ARCH=arm64
export ARCHV=aarch64
export CROSS_COMPILE=aarch64-linux-android-
export PATH=/opt/toolchains/aarch64-linux-android-4.9/bin:$PATH
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export PATH=$JAVA_HOME/bin:$PATH

source build/envsetup.sh
lunch odroidn1-eng

CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
ROOT_DIR=$(pwd)

make -j$CPU_JOB_NUM

./mkimage.sh

make -j$CPU_JOB_NUM updatepackage selfinstall
