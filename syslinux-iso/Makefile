ver=$(shell date +%Y.%m.%d)

WORKDIR=work

ARCH?=$(shell uname -m)

PWD=$(shell pwd)
NETname=$(PWD)/archlinux-$(ver)-netinstall-$(ARCH).iso
COREname=$(PWD)/archlinux-$(ver)-core-$(ARCH).iso

PACKAGES="$(shell cat packages.$(ARCH))"

kver_FILE=$(WORKDIR)/root-image/etc/mkinitcpio.d/kernel26.kver

all: net-iso core-iso

# Rules for each type of image
core-iso: $(COREname)
net-iso: $(NETname)

$(COREname): core-pkgs base-fs
	mkarchiso iso $(WORKDIR) $@
$(NETname): base-fs
	mkarchiso iso $(WORKDIR) $@

# This is the main rule for make the working filesystem.
base-fs: root-image bootfiles initcpio overlay iso-mounts


# Rules for make the root-image for base filesystem.
root-image: $(WORKDIR)/root-image/.arch-chroot
$(WORKDIR)/root-image/.arch-chroot:
	mkarchiso -p base create $(WORKDIR)
	mkarchiso -p $(PACKAGES) create $(WORKDIR)

# Rule for make /boot
bootfiles: root-image
	mkdir -p $(WORKDIR)/iso/boot
	cp $(WORKDIR)/root-image/boot/System.map26 $(WORKDIR)/iso/boot/
	cp $(WORKDIR)/root-image/boot/vmlinuz26 $(WORKDIR)/iso/boot/
	cp $(WORKDIR)/root-image/boot/memtest86+/memtest.bin $(WORKDIR)/iso/boot/memtest
	cp $(WORKDIR)/root-image/usr/share/licenses/common/GPL2/license.txt $(WORKDIR)/iso/boot/memtest.COPYING
	cp -r boot-files/* $(WORKDIR)/iso/boot/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/*.c32 $(WORKDIR)/iso/boot/syslinux/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/poweroff.com $(WORKDIR)/iso/boot/syslinux/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/isolinux.bin $(WORKDIR)/iso/boot/syslinux/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/memdisk $(WORKDIR)/iso/boot/syslinux/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/pxelinux.0 $(WORKDIR)/iso/boot/syslinux/
	cp $(WORKDIR)/root-image/usr/lib/syslinux/gpxelinux.0 $(WORKDIR)/iso/boot/syslinux/
	cp env.sh $(WORKDIR)/iso/
	# Add pci.ids and modules.alias for hdt
	mkdir -p $(WORKDIR)/iso/boot/syslinux/hdt/
	wget -O - http://pciids.sourceforge.net/v2.2/pci.ids | gzip -9 > $(WORKDIR)/iso/boot/syslinux/hdt/pciids.gz
	cat $(WORKDIR)/root-image/lib/modules/$(shell grep ^ALL_kver $(kver_FILE) | cut -d= -f2)/modules.alias | gzip -9 > $(WORKDIR)/iso/boot/syslinux/hdt/modalias.gz

# Rules for initcpio images
initcpio: $(WORKDIR)/iso/boot/archiso.img
$(WORKDIR)/iso/boot/archiso.img: mkinitcpio.conf $(WORKDIR)/root-image/.arch-chroot
	mkdir -p $(WORKDIR)/iso/boot
	mkinitcpio -c ./mkinitcpio.conf -b $(WORKDIR)/root-image -k $(shell grep ^ALL_kver $(kver_FILE) | cut -d= -f2) -g $@


# overlay filesystem
overlay:
	mkdir -p $(WORKDIR)/overlay/etc/pacman.d
	cp -r overlay $(WORKDIR)/
	wget -O $(WORKDIR)/overlay/etc/pacman.d/mirrorlist http://www.archlinux.org/mirrorlist/all/
	sed -i "s/#Server/Server/g" $(WORKDIR)/overlay/etc/pacman.d/mirrorlist


# Rule to process isomounts file.
iso-mounts: $(WORKDIR)/isomounts
$(WORKDIR)/isomounts: isomounts root-image
	sed "s|@ARCH@|$(ARCH)|g" isomounts > $@


# Rule for make the [core] repo packages
core-pkgs:
	./download-repo.sh core $(WORKDIR)/core-pkgs/src/core/pkg


# Clean-up all work
clean:
	rm -rf $(WORKDIR) $(NETname) $(COREname)


.PHONY: all core-iso net-iso
.PHONY: base-fs
.PHONY: root-image bootfiles initcpio overlay iso-mounts
.PHONY: core-pkgs
.PHONY: clean
