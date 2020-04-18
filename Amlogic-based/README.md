# Amlogic SOCs

The [Linux Meson](http://linux-meson.com/doku.php) project is there to bring Amlogic SoC support into the mainline Linux kernel.

As of 4/2020 this is in a bootable state, although not all distributions are using the mainline kernel yet.

Unfortunately, the Linux Meson project's documentation on how to boot into e.g., Debian using the mainline kernel is not very clear. Any insights appreciated.

## Booting

Booting Amlogic SOCs requires, besides a Linux kernel and initrd, a bootloader (an older version of U-Boot is normally preinstalled on the boxes), and a dtb file matching to the exact hardware device (box) you are using.

A newer approach to booting is using EFI. The Amlogic Meson project has been working on bringing EFI support for Amlogic SoCs into mainline U-Boot. Seemingly, as long as there is a bootloader installed to the internal memory of the device, the device will ignore bootloaders on SD card or USB (please correct if this is wrong). So there is apparently no good way to test a new U-Boot build without having to mess with the stock bootloader.
