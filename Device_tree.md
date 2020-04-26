# Device tree

Information about the hardware is stored in a device tree, also known as dts (device tree source) and dtb (device tree binary).
The dtb must match the hardware of the machine. Most Amlogic-based retail products are based on some reference boards, the names of which start with p (e.g., p281).

## Device tree compatibility over time

According to https://groups.io/g/u-boot-amlogic/message/181,

> The mainline u-boot syncs the mainline Linux device tree, which was entirely rewritten to match
the standard rules and requirements of upstream development, so you can't use the amlogic linux
device tree files.

This means that if we use the very latest (mainline) U-Boot and/or Linux kernel, then we may need to use a newer dtb thank what comes with the device from the factory as well.

## Reading device tree properties

In a booted Linux system, device tree properties can be read by using `fdtget`. http://manpages.ubuntu.com/manpages/trusty/man1/fdtget.1.html

## Changing device tree properties in U-Boot

It seems to be possible to override device tree properties in U-Boot boot scripts. To be written.

## Device tree collections

Debian provides device tree binaries (dtb): 
* Amlogic: http://ftp.inwx.de/debian/dists/sid/main/installer-arm64/current/images/device-tree/amlogic/

The kernel source provides device tree sources (dts):
* Amlogic: https://github.com/torvalds/linux/tree/master/arch/arm64/boot/dts/amlogic

KernelCI provides device tree binaries (dtb) that are probably in close sync to what is in the kernel source:
* Amlogic: https://storage.kernelci.org/pm/testing/v5.6-141-g61fafa3ac67b/arm64/defconfig/gcc-8/dtbs/amlogic/?C=M&O=A
