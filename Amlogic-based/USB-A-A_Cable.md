# USB A-A Cable

An USB A-A Cable can be used to communicate with Amlogic-based devices (e.g., to read or flash images, and to interact with the U-Boot bootloader) in cases where it is not possible to use a serial console. 

## Quick summary

* Take a USB extension cord and cut off the metal can on the "extension" side. Get an USB A-A cable. Plug into OTG port on the device __while the reset button is pressed__. No need to short any pins on any chips! `lsusb` should show `ID 1b8e:c003 Amlogic, Inc.`
* Follow https://forum.khadas.com/t/burning-tools-for-linux-pc/1832 to install the burning tool for Linux

This __works__:

```
sudo apt-get -y install libusb-dev git
git clone https://github.com/khadas/utils
cd utils/aml-flash-tool
git checkout 7c25838 # Later ones fail with: ERR: AmlUsbBulkCmd failed!
sudo ./INSTALL
update identify
aml-flash-tool/tools/update mread store boot normal 0x2000000 boot.dump # How do we know the correct length of the partitions?
```

## Longer version

Use a USB A-A cable. Those are uncommon. If you don't have one, you can turn a USB A extension cable into one by removing the outer shield from the female part of the cable to turn it into a male one (be careful, such a cable is very fragile; better buy a proper one). This cable needs to go into the USB OTG port; on the x96 this is the port that is next to the IR jack. You know that you have the correct port when you can see in your dmesg output:

```
[22000.482720] usb 9-2.3: new high-speed USB device number 42 using xhci_hcd
[22000.597521] usb 9-2.3: New USB device found, idVendor=1b8e, idProduct=c003, bcdDevice= 0.07
[22000.597523] usb 9-2.3: New USB device strings: Mfr=0, Product=0, SerialNumber=0
[22003.849173] usb 9-2.3: USB disconnect, device number 42
```

If there is a valid bootloader on the internal NAND eMMC memory, then this device will disconnect immediately. To make it permanent, we need to hold the reset button pressed while power-up, __or__ shorten the shown pins on the NAND eMMC chip (in my case, SAMSUNG KMLAG...) while plugging in the USB A-A cable.

![](https://forum.freaktab.com/filedata/fetch?id=638047&d=1490467056)

If this is done correctly, the blue LED will turn red and stay red, and the USB device will show up in dmesg like this:

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
```

returns nothing. (Or does it just print the output on the serial connection rather than over USB?)


If you are getting

```
AmlUsbBulkCmd[printenv]
AM_REQ_BULK_CMD_Handler ret=-110,blkcmd=printenv error_msg=error sending control message: Connection timed out
[AmlUsbRom]Err:rettemp = 0 buffer = [printenv]
ERR: AmlUsbBulkCmd failed!
```

and when this happens, `dmesg` says (see the last line):

```
[  311.668707] usb 9-2.3: usbfs: process 13176 (update) did not claim interface 0 before use
[  318.100690] usb 9-2.3: usbfs: process 13179 (update) did not claim interface 0 before use
```

then you need to try with another (older) version of the `update` tool (e.g., 7c25838 from https://github.com/khadas/utils does not seem to have this issue).

## TODO

* Can we dump ALL internal memory at once? Including the partition table and _everything_
