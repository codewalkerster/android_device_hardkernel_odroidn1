#!/bin/sh
if [ -e "/storage/internal/boot.ini" ]
then
    break
else
    cp /system/etc/boot.ini.template /storage/internal/boot.ini
fi
