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
