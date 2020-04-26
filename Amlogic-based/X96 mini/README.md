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

## Amlogic U-Boot Custodian Tree

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

In https://groups.io/g/u-boot-amlogic/message/178, a project leader states

> we don't support reference designs for S905W since this soc is not sold for SBCs, but only on final products.

This is a pity. SBCs are usually way worse in terms of price-performance ratio than retail products. So the project should really consider to also support those. SBCs and reference boards are useful during the development process while no retail products are available yet, but with the wide availability of retail products those are much preferred by end users.

The reason may be [this](https://groups.io/g/u-boot-amlogic/message/181):

> We always avoided replacing the bootloader of a closed device, because we don't have the source of
the FIP components (DDR setup, Power Pins & PWM, DVFS table), and usually these boxes has custom
setups that could diverge from the reference designs.

But:

> If you feel confident enough, you'll need to dump the eMMC content to save the original
bootloader (in the first 4MiB) and use the p281 amlogic u-boot config to generate the FIP
binaries as explained in the mainline README file of P212.

It looks like here someone has added support for p281:
https://github.com/arnarg/u-boot/commit/167be0c207e6be5e710355d33a89fe4e8091ba3d

Can we compile this? Can we confirm this works on the x96 mini? Can we then get it into the [Amlogic U-Boot Custodian Tree](https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic)?
