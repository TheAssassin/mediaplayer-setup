# USB A-A Cable

By shorting these pins e.g., with a DuPont male cable, we can get the device disregard what is stored in the internal memory. This allows us to use the Amlogic flash tools.

![](https://forum.freaktab.com/filedata/fetch?id=638047&d=1490467056)

Use a USB A-A cable. Those are uncommon. If you don't have one, you can turn a USB A extension cable into one by removing the outer shield from the female part of the cable to turn it into a male one (be careful, such a cable is very fragile; better buy a proper one). This cable needs to go into the USB OTG port; on the x96 this is the port that is next to the IR jack. You know that you have the correct port when you can see in your dmesg output:

```
[22000.482720] usb 9-2.3: new high-speed USB device number 42 using xhci_hcd
[22000.597521] usb 9-2.3: New USB device found, idVendor=1b8e, idProduct=c003, bcdDevice= 0.07
[22000.597523] usb 9-2.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[22003.849173] usb 9-2.3: USB disconnect, device number 42
```

If there is a valid bootloader on the internal NAND eMMC memory, then this device will disconnect immediately. To make it permanent, we need to shorten the shown pins on the NAND eMMC chip (in my case, SAMSUNG KMLAG...) while plugging in the USB A-A cable. If this is done correctly, the blue LED will turn red and stay red, and the USB device will show up in dmesg like this:

```
[22181.037732] usb 9-2.3: New USB device found, idVendor=1b8e, idProduct=c003, bcdDevice= 0.20
[22181.037735] usb 9-2.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[22181.037738] usb 9-2.3: Product: GX-CHIP
[22181.037740] usb 9-2.3: Manufacturer: Amlogic
```

```
sudo apt-get -y install libusb-dev git
git clone https://github.com/khadas/utils
cd utils/
sudo ./INSTALL

sudo aml-flash-tool/tools/linux-x86/update chipid

AmlUsbIdentifyHost
This firmware version is 2-2-0-0
[update]idVer is 0x202
ChipID is:0x8c1896fca82342cf25ecc4cf
```

But it is not fully functional:

```
sudo aml-flash-tool/tools/linux-x86/update  bulkcmd "printenv"
AmlUsbBulkCmd[printenv]
AM_REQ_BULK_CMD_Handler ret=-110,blkcmd=printenv error_msg=error sending control message: Connection timed out
[AmlUsbRom]Err:rettemp = 0 buffer = [printenv]
ERR: AmlUsbBulkCmd failed!
```

When this happens, `dmesg` says (see the last line):

```
[21625.726837] usb 9-2.3: New USB device found, idVendor=1b8e, idProduct=c003, bcdDevice= 0.20
[21625.726840] usb 9-2.3: New USB device strings: Mfr=1, Product=2, SerialNumber=0
[21625.726842] usb 9-2.3: Product: GX-CHIP
[21625.726844] usb 9-2.3: Manufacturer: Amlogic
[21687.253525] usb 9-2.3: usbfs: USBDEVFS_CONTROL failed cmd update rqt 64 rq 52 len 64 ret -110
```

I get this on Ubuntu 16.04 (one of the supposedly supported systems). On that system I get in dmesg:

```
[  311.668707] usb 9-2.3: usbfs: process 13176 (update) did not claim interface 0 before use
[  318.100690] usb 9-2.3: usbfs: process 13179 (update) did not claim interface 0 before use
```

FIXME: How can this be fixed?

## TODO

* Try on another desktop machine
* As a last resort try with the Windows flashing tools (did not get those to work either due to some missing dlls)
