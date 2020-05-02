# X96 mini

The X96 mini is an Amlogic S905W SOC based media player. It's *really* small (around 82x82x17mm plus maybe 1mm of rubber "feet"), and gets quite warm during operation.

The device is available with 1G RAM/8G NAND and 2G RAM/16G NAND. It ships with some Android 7.1.2.


## Booting other distributions

The device uses some sort of U-Boot bootloader. You can boot other distributions from a MicroSD card. You need an Android-style "boot partition" with a `dtb.img` etc., otherwise it won't come up.

It should boot automatically from MicroSD. If not, you can try holding the micro switch hidden inside the AV port with some non-conducting material (e.g., a cut off toothpick).

Booting has worked well so far. There's a UART port expected to be inside, but so far there was no need to open one of those devices up.


## Teardown

Due to severe thermal issues, the device was opened up to see what's going on. WIP in [Teardown](Teardown.md).


## Tested distros

- CoreELEC (see [CoreELEC](CoreELEC.md) for more information)


## Serial port

A 3d printed pogo pin fixture has been used to access the tiny serial port solder points using P50-B1 0.68mm pogo pins.

Note that what looks like test points does not seem to be actually connected, I had to use the inner row of what looks like unpopulated resistor footprints.

## U-Boot

From the stock U-Boot, we can access USB devices like this:

```
gxl_p281_v1#usb start
(Re)start USB...
USB0:   USB3.0 XHCI init start
Register 2000140 NbrPorts 2
Starting the controller
USB XHCI 1.00
scanning bus 0 for devices... 2 USB Device(s) found
       scanning usb for storage devices... init_part() 278: PART_TYPE_DOS
1 Storage Device(s) found

gxl_p281_v1#usb storage
  Device 0: Vendor: Kingston Rev:  Prod: DataTraveler 3.0
            Type: Removable Hard Disk
            Capacity: 7377.6 MB = 7.2 GB (15109516 x 512)
```

### Amlogic U-Boot Custodian Tree

The [Amlogic U-Boot Custodian Tree](https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic) is a branch of the official (upstream) U-Boot project in which the Amlogic-related work is happening. __It seems like there is no U-Boot configuration for p281 (Amlogic S905W)__  (which is used in retail products with especially good price-performance ratio such as X96 mini). How to solve this? According to http://linux-meson.com/doku.php, the Amlogic S905W is similar to the Amlogic S905X, so we might try to use U-Boot for p212 (e.g., LibreTech AC, LibreTech CC). Unfortunately, this __does not work__:

```
gxl_p281_v1#mmc rescan
init_part() 278: PART_TYPE_DOS
[mmc_init] mmc init success
gxl_p281_v1#fatks mmc 0
Unknown command 'fatks' - try 'help'
gxl_p281_v1#fatls mmc 0
(...)
   684983   u-boot.ac 

7 file(s), 2 dir(s)

gxl_p281_v1#fatload mmc 0 ${loadaddr} u-boot.ac
reading u-boot.ac
684983 bytes read in 41 ms (15.9 MiB/s)
gxl_p281_v1#go ${loadaddr}
## Starting application at 0x01080000 ...

# (Stalled here)
```

In https://groups.io/g/u-boot-amlogic/message/178, the maintainer of the Amlogic U-Boot Custodian Tree states

> we don't support reference designs for S905W since this soc is not sold for SBCs, but only on final products.

This is a pity. SBCs are usually way worse in terms of price-performance ratio than retail products. So the project should really consider to also support those. SBCs and reference boards are useful during the development process while no retail products are available yet, but with the wide availability of retail products those are much preferred by end users.

The reason may be [this](https://groups.io/g/u-boot-amlogic/message/181):

> We always avoided replacing the bootloader of a closed device, because we don't have the source of
the FIP components (DDR setup, Power Pins & PWM, DVFS table), and usually these boxes has custom
setups that could diverge from the reference designs.

What is especially confusing is that the Amlogic P281 Reference Design is explicitly listed on http://linux-meson.com/doku.php?id=hardware under "Supported Hardware", so it seems reasonable to assume it to be supported.

But:

> If you feel confident enough, you'll need to dump the eMMC content to save the original
bootloader (in the first 4MiB) and use the p281 amlogic u-boot config to generate the FIP
binaries as explained in the mainline README file of P212.

__TODO:__ Do this.

### arnarg tx3-mini-uboot-build U-Boot

It looks like here [someone has added support for p281](https://www.codedbearder.com/posts/mainline-linux-on-tx3-mini/) in a private branch:
https://github.com/arnarg/u-boot/commit/167be0c207e6be5e710355d33a89fe4e8091ba3d

Can we compile this? Can we confirm this works on the x96 mini? Can we then get it into the [Amlogic U-Boot Custodian Tree](https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic)?

Conveniently, there are binaries:

https://github.com/arnarg/tx3-mini-uboot-build/releases


Unfortunately, trying to run this crashes the x96 mini, causing a reboot:

```
fatls mmc 0
fatload mmc 0 ${loadaddr} u-boot.arnarg
go ${loadaddr}

## Starting application at 0x01080000 ...
"Synchronous Abort" handler, esr 0x02000000
ELR:     1080000
LR:      37ebf288
x0 : 0000000000000001 x1 : 0000000033eb88c8
x2 : 0000000033eb88c8 x3 : 0000000001080000
x4 : 0000000000000030 x5 : 0000000000000000
x6 : 00000000ffffffd0 x7 : 0000000000000004
x8 : 0000000000000031 x9 : 0000000000000000
x10: 000000000000000f x11: 0000000037f38d00
x12: 0000000000000000 x13: 0000000000000000
x14: 0000000000000000 x15: 0000000000000000
x16: 0000000000000000 x17: 0000000000000000
x18: 0000000033ea2e28 x19: 0000000033eb88c8
x20: 0000000000000002 x21: 0000000001080000
x22: 0000000000000002 x23: 0000000037f71fc0
x24: 0000000000000000 x25: 0000000000000000
x26: 0000000000000000 x27: 0000000033eb8920
x28: 0000000000000000 x29: 0000000033ea2930

Resetting CPU ...
```

Why?
Perhaps we need to rebuild this using https://github.com/torvalds/linux/blob/master/arch/arm64/boot/dts/amlogic/meson-gxl-s905w-p281.dts instead of https://github.com/torvalds/linux/blob/master/arch/arm64/boot/dts/amlogic/meson-gxl-s905w-tx3-mini.dts, although the differences seem to be minor?

So as of April 2020 it seems like we need to compile our own U-Boot binary, which we can do using https://github.com/TheAssassin/mediaplayer-setup/blob/master/Amlogic-based/X96%20mini/build-u-boot.sh. Unfortunately, trying to use this U-Boot leads to an instant reboot (FIXME).

### hexdump0815 U-Boot

https://github.com/hexdump0815/imagebuilder/blob/master/boot/boot-amlogic_gx-aarch64/u-boot.bin can be chainloaded on the x96 mini (note: a different load address has to be used!), but trying to use `usb start` leads to an instant reboot:

```
gxl_p281_v1#fatload mmc 0 0x01000000 u-boot.ext
(...)
gxl_p281_v1#go 0x01000000
## Starting application at 0x01000000 ...
U-Boot 2019.01 (Mar 26 2019 - 22:16:31 +0100) libretech-cc
DRAM:  1 GiB
MMC:   mmc@72000: 0, mmc@74000: 1
(...)
Hit any key to stop autoboot:  2 
(...)
=> usb start
starting USB...
USB0:   Register 2000140 NbrPorts 2
Starting the controller
USB XHCI 1.00
scanning bus 0 for devices... XHCI timeout on event type 33... cannot recover.
BUG at drivers/usb/host/xhci-ring.c:473/xhci_wait_for_event()!
BUG!
resetting ...
bl31 reboot reason: 0xd
bl31 reboot reason: 0x0
system cmd  1.
GXL:BL1:9ac50e:bb16dc;FEAT:ADFC318C:0;POC:3;RCY:0;EMMC:0;READ:0;0.0;CHK:0;
```

What may be causing this, how to debug it?

As per https://github.com/hexdump0815/imagebuilder/issues/4#issuecomment-622318012,  it __works__ (as in: recognizes USB mass storage device without crashing) when one runs `usb start` before _and_ after chainloading. Does this mean that some (which?) aspects of the stock U-Boot need to be carried over/compiled into the new one?


# openSUSE U-Boot built for libretech-cc

https://build.opensuse.org/package/binaries/hardware:boot/u-boot:libretech-cc/openSUSE_Factory_ARM can be used to some extent:

Note `0x01000000` being used instead of `${loadaddr}`:

```
gxl_p281_v1#fatload mmc 0 0x01000000 u-boot.ext
(...)
gxl_p281_v1#go 0x01000000
## Starting application at 0x01000000 ...

U-Boot 2020.04 (Apr 17 2020 - 12:05:54 +0000) libretech-cc

Model: Libre Computer Board AML-S905X-CC
SoC:   Amlogic Meson GXL (S905W) Revision 21:d (a4:2)
DRAM:  1 GiB
MMC:   mmc@72000: 0, mmc@74000: 1
In:    serial
Out:   serial
Err:   serial
[BL31]: tee size: 0
[BL31]: tee size: 0
Net:   eth0: ethernet@c9410000
Hit any key to stop autoboot:  0
=>
=>
=> version
U-Boot 2020.04 (Apr 17 2020 - 12:05:54 +0000) libretech-cc

gcc (SUSE Linux) 9.3.1 20200406 [revision 6db837a5288ee3ca5ec504fbd5a765817e556ac2]
GNU ld (GNU Binutils; openSUSE Tumbleweed) 2.34.0.20200325-1
```

Here, too, we have the USB issue:

```
=> usb start
starting USB...
Bus dwc3@c9000000: Register 2000140 NbrPorts 2
Starting the controller
USB XHCI 1.00
scanning bus dwc3@c9000000 for devices... Device not responding to set address.

      USB device not accepting new address (error=80000000)
1 USB Device(s) found
       scanning usb for storage devices... 0 Storage Device(s) found
=> 
```

The following works:

```
gxl_p281_v1#usb start
fatload mmc 0 0x01000000 u-boot.cc
go 0x01000000
usb start
```

But we still cannot quite boot the openSUSE Live image from USB:

```
=> usbboot usb 0

Loading from usb device 0, partition 1: Name: usbda1  Type: U-Boot
BUG at drivers/usb/host/xhci-mem.c:37/xhci_flush_cache()!
BUG!
resetting ...
bl31 reboot reason: 0xd
bl31 reboot reason: 0x0
system cmd  1.

(reboot)
GXL:BL1:9ac50e:bb16dc;FEAT:ADFC318C:0;POC:3;RCY:0;EMMC:0;READ:0;0.0;CHK:0;
```
