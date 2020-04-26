# Device tree

Information about the hardware is stored in a device tree, also known as dtb (device tree binary).
The dtb must match the hardware of the machine. Most Amlogic-based retail products are based on some reference boards, the names of which start with q.

## Reading device tree properties

In a booted Linux system, device tree properties can be read by using `fdtget`. http://manpages.ubuntu.com/manpages/trusty/man1/fdtget.1.html

## Changing device tree properties in U-Boot

It seems to be possible to override device tree properties in U-Boot boot scripts. To be written.
