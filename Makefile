WORKDIR=work
PACKAGES="$(shell cat packages.list) syslinux"
NAME=concerto_player_ng
VER=0.1
kver_FILE=$(WORKDIR)/root-image/etc/mkinitcpio.d/kernel26.kver
ARCH?=$(shell uname -m)
PWD:=$(shell pwd)
FULLNAME="$(PWD)"/$(NAME)-$(VER)-$(ARCH)

all: concerto_player_ng

concerto_player_ng: base-fs
	mkarchiso -p syslinux iso "$(WORKDIR)" "$(FULLNAME)".iso

base-fs: root-image boot-files initcpio overlay iso-mounts syslinux

root-image: "$(WORKDIR)"/root-image/.arch-chroot
"$(WORKDIR)"/root-image/.arch-chroot:
	mkarchiso -p $(PACKAGES) create "$(WORKDIR)"

boot-files: root-image
	cp -r "$(WORKDIR)"/root-image/boot "$(WORKDIR)"/iso
	cp -r boot-files/* "$(WORKDIR)"/iso/boot

initcpio: "$(WORKDIR)"/iso/boot/concerto_player_ng.img

"$(WORKDIR)"/iso/boot/concerto_player_ng.img: mkinitcpio.conf "$(WORKDIR)"/root-image/.arch-chroot
	mkdir -p "$(WORKDIR)"/iso/boot
	mkinitcpio -c ./mkinitcpio.conf -b "$(WORKDIR)"/root-image -k $(shell grep ^ALL_kver $(kver_FILE) | cut -d= -f2) -g $@

overlay:
	mkdir -p "$(WORKDIR)"/overlay/etc/pacman.d
	cp -r overlay "$(WORKDIR)"/
	wget -O "$(WORKDIR)"/overlay/etc/pacman.d/mirrorlist http://www.archlinux.org/mirrorlist/all/
	sed -i "s/#Server/Server/g" "$(WORKDIR)"/overlay/etc/pacman.d/mirrorlist

iso-mounts: "$(WORKDIR)"/isomounts
"$(WORKDIR)"/isomounts: isomounts root-image
	sed "s|@ARCH@|$(ARCH)|g" isomounts > $@

syslinux: root-image
	mkdir -p $(WORKDIR)/iso/boot/syslinux
	cp $(WORKDIR)/root-image/usr/lib/syslinux/*.c32 $(WORKDIR)/iso/boot/syslinux/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/isolinux.bin $(WORKDIR)/iso/boot/syslinux/

clean:
	rm -rf "$(WORKDIR)" "$(FULLNAME)".img "$(FULLNAME)".iso

.PHONY: all concerto_player_ng
.PHONY: base-fs
.PHONY: root-image boot-files initcpio overlay iso-mounts
.PHONY: syslinux
.PHONY: clean
