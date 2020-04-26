# Device tree

Information about the hardware is stored in a device tree, also known as dts (device tree source) and dtb (device tree binary).
The dtb must match the hardware of the machine. Most Amlogic-based retail products are based on some reference boards, the names of which start with p (e.g., p281).

## Reading device tree properties

In a booted Linux system, device tree properties can be read by using `fdtget`. http://manpages.ubuntu.com/manpages/trusty/man1/fdtget.1.html

## Changing device tree properties in U-Boot

It seems to be possible to override device tree properties in U-Boot boot scripts. To be written.


## Device tree collections

Debian provides device tree binaries (dtb): 
* Amlogic: http://ftp.inwx.de/debian/dists/sid/main/installer-arm64/current/images/device-tree/amlogic/

The kernel source provides device tree sources (dts):
* Amlogic: https://github.com/torvalds/linux/tree/master/arch/arm64/boot/dts/amlogic
