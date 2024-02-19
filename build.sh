#!/bin/bash
set -ex
if [[ -d work ]] ; then
    rm -rf work
fi
if [[ ! -f etap5.3-rootfs.tar.gz ]] ; then
    wget https://github.com/my-garbage-stuff/binary-stuff/releases/download/3.1/etap5.3-rootfs.tar.gz
fi
export DEBIAN_FRONTEND=noninteractive
mkdir work
cd work
tar -xf ../etap5.3-rootfs.tar.gz
echo "nameserver 1.1.1.1" > chroot/etc/resolv.conf
chroot chroot apt update
chroot chroot apt install --no-install-recommends \
    xserver-xorg-core \
    xserver-xorg-video-all \
    xserver-xorg-input-all \
    xinit \
    x11-utils \
    x11-xkb-utils \
    x11-xserver-utils -y --force-yes
chroot chroot apt install linux-image-amd64 \
    live-boot live-config \
    --force-yes --no-install-recommends -y
echo -e "root\nroot\n" | chroot chroot passwd root
mkdir isowork/live isowork/boot/grub/ -p
mksquashfs chroot isowork/live/filesystem.squashfs -comp gzip -wildcards
cp -pf chroot/boot/initrd.img-* isowork/initrd.img
cp -pf chroot/boot/vmlinuz-* isowork/vmlinuz
mkdir -p isowork/boot/grub/
echo 'linux /vmlinuz boot=live init=/bin/bash live-config quiet --' >> isowork/boot/grub/grub.cfg
echo 'initrd /initrd.img' >> isowork/boot/grub/grub.cfg
echo 'boot' >> isowork/boot/grub/grub.cfg
grub-mkrescue isowork -o etap-test.iso
