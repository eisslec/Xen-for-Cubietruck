#!/bin/sh
#set -x
mount -o remount,rw /
mount -t proc none /proc
mount -t sysfs none /sys

hostname -F /etc/hostname

#mknod -m 640 /dev/xconsole p
#chown root:adm /dev/xconsole

#/sbin/klogd -c 1 -x
#/usr/sbin/syslogd 

#/etc/init.d/xencommons start

#echo 9 > /proc/sysrq-trigger 

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export HOME=/root
exec /bin/bash

ifup eth0
ip addr show dev eth0
/etc/init.d/networking restart
