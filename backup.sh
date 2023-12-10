#! /bin/bash

rm -rf var/cache/*
tar -cvf $(cat etc/hostname)-rootfs-$(date +%F).tar bin boot dev etc lib lib64 media mnt opt proc root run sbin swapfile sys tmp usr var

