#  X96 (non-mini)

Content from https://gist.github.com/probonopd/d4f0a3c7105b8378bc10eebe7f2d7de9 to be transferred here

## Serial port

A 3d printed pogo pin fixture has been used to access the tiny serial port test points using P50-B1 0.68mm pogo pins.

## Chainloading upstream U-Boot
This S905X device can be booted using https://build.opensuse.org/package/binaries/hardware:boot/u-boot:khadas-vim/openSUSE_Factory_ARM, see https://en.opensuse.org/HCL:Khadas_Vim.

To do this, place the `u-boot.bin` file from openSUSE into the BOOT partition of @150balbes Armbian, and call it `u-boot.ext`. Watch from a serial console what is going on:

```
reading s905_autoscript
1654 bytes read in 3 ms (538.1 KiB/s)
## Executing script at 01020000
start amlogic old u-boot
## Error: "bootfromsd" not defined
reading boot_android
** Unable to read file boot_android **
** Bad device usb 0 **
reading u-boot.ext
622278 bytes read in 39 ms (15.2 MiB/s)
## Starting application at 0x01000000 ...
U-Boot 2020.04 (Apr 17 2020 - 12:05:54 +0000) khadas-vim
Model: Khadas VIM
SoC:   Amlogic Meson GXL (S905X) Revision 21:a (82:2)
DRAM:  2 GiB
MMC:   mmc@70000: 0, mmc@72000: 1, mmc@74000: 2
In:    serial
Out:   serial
Err:   serial
[BL31]: tee size: 0
[BL31]: tee size: 0
Net:   eth0: ethernet@c9410000
Hit any key to stop autoboot:  2 
Card did not respond to voltage select!
switch to partitions #0, OK
mmc1 is current device
** Invalid partition 3 **
** Invalid partition 4 **
Scanning mmc 1:2...
Scanning mmc 1:1...
Found U-Boot script /boot.scr
1029 bytes read in 1 ms (1004.9 KiB/s)
## Executing script at 08000000
start mainline u-boot
## Error: "bootfromsd" not defined
1630 bytes read in 2 ms (795.9 KiB/s)
## Error: "mac" not defined
## Error: "eth_mac" not defined
ethaddr=de:34:8b:xx:xx:xx
27798016 bytes read in 1189 ms (22.3 MiB/s)
11256987 bytes read in 484 ms (22.2 MiB/s)
27532 bytes read in 5 ms (5.3 MiB/s)
## Loading init Ramdisk from Legacy Image at 13000000 ...
   Image Name:   uInitrd
   Image Type:   AArch64 Linux RAMDisk Image (gzip compressed)
   Data Size:    11256923 Bytes = 10.7 MiB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
## Flattened Device Tree blob at 08008000
   Booting using the fdt blob at 0x8008000
   Loading Ramdisk to 7d488000, end 7df4445b ... OK
   Loading Device Tree to 000000007d47e000, end 000000007d487b8b ... OK
Starting kernel ...
[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
[    0.000000] Linux version 5.6.2-arm-64 (root@vbox) (gcc version 8.3.0 (GNU Toolchain for the A-profile Architecture 8.3-2019.03 (arm-rel-8.36))) #20.05.1 SMP PREEMPT Wed Apr 8 15:18:14 MSK 2020
[    0.000000] Machine model: Amlogic Meson GXL (S905X) P212 Development Board
```

__It is working__, we can see that the original u-boot on the device is loading the `u-boot.ext` from the SD card, which in turn is booting the systen.

__HDMI output with this u-boot is still to be verified.__

We may now try to load openSUSE ISO using `efiboot` and `grub.efi`...

```
gxl_p212_v1#usb init
Unknown command 'usb' - try 'help'
gxl_p212_v1#usb start
(Re)start USB...
USB0:   USB3.0 XHCI init start
Register 2000140 NbrPorts 2
Starting the controller
USB XHCI 1.00
scanning bus 0 for devices... Device not responding to set address.

      USB device not accepting new address (error=80000000)
1 USB Device(s) found
       scanning usb for storage devices... 0 Storage Device(s) found
gxl_p212_v1#usb tree
USB device tree:
  1  Hub (5 Gb/s, 0mA)
     u-boot XHCI Host Controller 
   
gxl_p212_v1#
USB device tree:
  1  Hub (5 Gb/s, 0mA)
     u-boot XHCI Host Controller 
   
gxl_p212_v1#usb reset
Host not halted after 16000 microseconds.
(Re)start USB...
USB0:   USB3.0 XHCI init start
Register 2000140 NbrPorts 2
Starting the controller
USB XHCI 1.00
scanning bus 0 for devices... Device not responding to set address.

      USB device not accepting new address (error=80000000)
1 USB Device(s) found
       scanning usb for storage devices... 0 Storage Device(s) found
```

__Why are we getting this error? Why can't we access USB mass storage devices from U-Boot here?__
