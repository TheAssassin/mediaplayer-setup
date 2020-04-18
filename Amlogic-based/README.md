# Amlogic SOCs

The [Linux Meson](http://linux-meson.com/doku.php) project is there to bring Amlogic SoC support into the mainline Linux kernel.

As of 4/2020 this is in a bootable state, although not all distributions are using the mainline kernel yet.

Unfortunately, the Linux Meson project's documentation on how to boot into e.g., Debian using the mainline kernel is not very clear. Any insights appreciated.

## Booting

Booting Amlogic SOCs requires, besides a Linux kernel and initrd, a bootloader (an older version of U-Boot is normally preinstalled on the boxes), and a dtb file matching to the exact hardware device (box) you are using.

### EFI booting

A newer approach to booting is using EFI. The Amlogic Meson project has been working on bringing EFI support for Amlogic SoCs into mainline U-Boot. This is said to have the advantage of being able to boot e.g., stock openSUSE ISOs without the need for manually setting up a boot partition.

Seemingly, as long as there is a bootloader installed to the internal memory of the device, the device will ignore bootloaders on SD card or USB (please correct if this is wrong). So there is apparently no good way to test a new U-Boot build without having to mess with the stock bootloader.

### USB booting

Unlike most Raspberry Pis, Amlogic devices can boot not only from SD card, but also from USB. This has been verified on a X96 mini and a Tanix TX92 by attaching a USB card reader and putting the SD card into that USB card reader. It still boots, even if the card reader is attached via a USB hub (a feat that even some Intel desktop machines don't manage to do).
