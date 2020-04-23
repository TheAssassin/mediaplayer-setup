# Amlogic SOCs

## Linux support

### Linux Meson

The [Linux Meson](http://linux-meson.com/doku.php) project is there to bring Amlogic SoC support into the mainline Linux kernel.

As of 4/2020 this is in a bootable state, although not all distributions are using the mainline kernel yet. The Linux Meson project works "upstream". This means that there are no downloadable images, but the idea is that Linux distributions will pick up the software sooner or later.

Unfortunately, the Linux Meson project's documentation on how to boot into e.g., Debian using the mainline kernel is not very clear. Any insights appreciated.

### LibreELEC, CoreELEC, AlexELEC

LibreELEC, CoreELEC, AlexELEC are media center focused distributions with builds for Armlogic systems. They ship with KODI.

### Armbian

Armbian is a project to run Debian and/or Ubuntu on ARM-based systems. Unfortunately they don't want to support retail products, only developer boards. Despite its name, this is not an official Debian project.

### @150balbes Armbian

@150balbes is a developer who is doing special Armbian builds for Amlogic-based retail products ("TV boxes"). Despite its name, this is not an official Armbian project and the Armbian project refuses to support his work.

### Debian, openSUSE, Fedora, Ubuntu,...

Those "mainstream" distributions are increasingly adding aarch64 builds and partly even ISO images. However, none of them are specifically built for Amlogic-based systems, and hence do not boot out of the box (possibly unless a EFI-capable U-Boot is used, to be verified).

## Booting

Booting Amlogic SOCs requires, besides a Linux kernel and initrd, a bootloader (an older version of U-Boot is normally preinstalled on the boxes), and a dtb file matching to the exact hardware device (box) you are using.

### EFI booting

A newer approach to booting is using EFI. The Amlogic Meson project has been working on bringing EFI support for Amlogic SoCs into mainline U-Boot. This is said to have the advantage of being able to boot e.g., stock openSUSE ISOs without the need for manually setting up a boot partition.

Seemingly, as long as there is a bootloader installed to the internal memory of the device, the device will ignore bootloaders on SD card or USB (please correct if this is wrong). So there is apparently no good way to test a new U-Boot build without having to mess with the stock bootloader.

### USB booting

Unlike most Raspberry Pis, Amlogic devices can boot not only from SD card, but also from USB. This has been verified on a X96 mini and a Tanix TX92 by attaching a USB card reader and putting the SD card into that USB card reader. It still boots, even if the card reader is attached via a USB hub (a feat that even some Intel desktop machines don't manage to do).

## Booting generic kernels in 64-bit Amlogic devices

__Work in progress. Contributions welcome.__

Amlogic systems are supposed to be able to boot generic "mainline" kernels. If we use a kernel from a rolling release distribution such as openSUSE Tumbleweed or Debian sid, we should be able to run the latest kernel on Amlogic devices.

@150balbes Armbian uses a `boot.cmd` compiled into a `boot.scr`  and `s905_autoscript.cmd` compiled into a `s905_autoscript` that uses `uEnv.txt` to configure boot parameters. At least in those scripts it is mandatory to have an `uInitrd`, otherwise it will not proceed to run the boot command.

## Trying to run mainline kernel from kernelci.org

kernelci.org is the closest thing to "upstream-packaged binaries" of the Linux kernel.

https://kernelci.org/soc/amlogic/ has known working kernels for many Amlogic devices.

__How can we boot them?__

It seems that they are using Linaro LAVA https://git.lavasoftware.org/lava/lava which roughly does:
* Download kernel
* Download kernel modules
* Download initrd
* Umpack initrd and put kernel modules inside
* Repack initrd
* Run kernel trough mkimage
* Run initrd through mkimage
* Communicate with the device over serial, enter U-Boot there
* Cause U-Boot to load the files over Ethernet (TFTP) and boot them

> LAVA is a continuous integration system for deploying operating systems onto physical and virtual hardware for running tests. Tests can be simple boot testing, bootloader testing and system level testing, although extra hardware may be required.

This seems to be the code that does it: https://git.lavasoftware.org/lava/lava/-/blob/master/lava_dispatcher/actions/deploy/apply_overlay.py

### Generate uInitrd

@150balbes Armbian automatically converts initrd to  `uInitrd` as required by running [this](https://github.com/150balbes/Build-Armbian/blob/master/packages/bsp/common/etc/initramfs/post-update.d/99-uboot) code:

```
mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /boot/initrd.img-* /boot/uInitrd
```

#### Trying openSUSE

Are we able to take an openSUSE Tumbleweed kernel and ramdisk and boot them on an Amlogic device?

The first issue is that the openSUSE initrd seems to be in a different format:

```
# Ubuntu
me@host:~$ file /boot/initrd.img-*
/boot/initrd.img-4.18.0-15-generic: ASCII cpio archive (SVR4 with no CRC)

# openSUSE
me@host:~$ sudo mount 'openSUSE-Tumbleweed-XFCE-Live-aarch64-Snapshot20200411-Media.iso' /mnt
me@host:~$ sudo file '/mnt/boot/aarch64/loader/initrd'
/mnt/boot/aarch64/loader/initrd: XZ compressed data
```

Does this matter? Let's try t o put the openSUSE kernel and initrd onto the `BOOT` partition of a @150balbes Armbian system:

```
me@host:~$ sudo mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /mnt/boot/aarch64/loader/initrd '/media/me/BOOT/uInitrd'

me@host:~$ sudo cp /mnt/boot/aarch64/loader/linux '/media/me/BOOT/zImage'
```

When trying to boot, the boot stalls at the Amlogic boot screen.

What happens if we try to run the openSUSE kernel with the @150balbes Armbian ramdisk? **It boots!** So we know that the Amlogic device can boot a openSUSE Tumbleweed kernel but we still need to do some work to get the openSUSE ramdisk loaded.

Maybe our mkimage command is wrong?

Let's try to extract the XZ initrd and recompress it as a gz one:

```
me@host:~$ sudo su
me@host:~$ mkdir initrd && cd initrd
me@host:~$ xz -dc < /mnt/boot/aarch64/loader/initrd | cpio -idmv
me@host:~$ find . | cpio -o -c | gzip -9 > ../initrdfile
cd ..
me@host:~$ sudo mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d initrdfile '/media/me/BOOT/uInitrd'
```

**It boots!** So we know that the Amlogic device can boot a openSUSE Tumbleweed kernel and a repacked openSUSE Tumbleweed initrd.

Without an openSUSE live image it cannot boot a root fs obviously. So we need to transfer that over, too.  And we need to change the kernel arguments in uEnv.txt. So copying the `LiveOS` directory to the `ROOTFS` partition. (Not clear whether the openSUSE ramdisk can boot it from there...)

```
append=root=live:LABEL=ROOTFS rd.live.image rd.live.overlay.persistent rd.live.overlay.cowfs=ext4
```

We see `RAMDISK: incomplete write (16269 != 27512)`. it is unclear whether this is the root cause why we end up with

here are the available partitions: ram0 - ram15, mmcblk1, 

`VFS: Unable to mount root fs on unknown-block(0,0)`

The openSUSE initrd is huge, whereas the @150balbes Armbian one is just around 15 MB.

Is this the culprit?

Do we have to change something in U-Boot?

Can we chainload a newer U-Boot (e.g., by renaming it `u-boot.ext`)?

It seems that it stalls on the Amlogic boot screen then... a serial console would be helpful here.
