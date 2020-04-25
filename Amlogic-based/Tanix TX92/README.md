# Tanix TX92

http://www.tanix-box.com/project-view/tanix-tx92-android-tv-box-powered-amlogic-s912/

The Tanix TX92 features an Octacore 64-bit Amlogic s812 SOC with a T820 GPU. 

As of 4/2020, this GPU is said to play video smoother in a Linux web browser than most others. In our tests, YouTube video plays smooth in Chrome on @150balbes Armbian in a window, and "almost smooth" in fullscreen.

This box has __RTL8211F Gigabit Ethernet__.

Apparently it is using a __Qualcomm QCA9377__ 802.11a/b/g/n/ac WLAN and Bluetooth 5 chip https://www.qualcomm.com/products/qca9377.

The Tanix TX92 is very well-built. Unlike with cheaper boxes, the PCB is mounted upward facing, hence the connectors are in the correct orientation.

## Stock ROM Android

The Android in the stock ROM is pre-rooted. Using Termux (installed from https://f-droid.org/), the `su` command conveniently works out of the box.

## dtb

The box is apparently available in different memory configurations, e.g., 2/16 GB. So far it is not clear which dtb is 100% working. Using `meson-gxm-q200.dtb` the system boots but WLAN and Bluetooth are not working (possibly only because the firmware for the QCA9377 is missing).

The stock rom U-Boot calls the board `gxm_q201_v1`, has `aml_dt=gxm_q201_2g` in `printenv`, and prints

```
      Amlogic multi-dtb tool
      Multi dtb detected
      Multi dtb tool version: v2 .
      Support 3 dtbs.
        aml_dt soc: gxm platform: q201 variant: 2g
        dtb 0 soc: gxm   plat: q201   vari: 1g
        dtb 1 soc: gxm   plat: q201   vari: 2g
        dtb 2 soc: gxm   plat: q201   vari: 3g
      Find match dtb: 1
```

## Running Desktop Linux

### @150balbes Armbian

@150balbes "Single Armbian image for RK + AML + AW" from https://forum.armbian.com/topic/12162-single-armbian-image-for-rk-aml-aw/ works on this box. Using `meson-gxm-q200.dtb` the system boots but WLAN and Bluetooth are not working.

The Armbian project does not want to support TV boxes nor the "Single Armbian image for RK + AML + AW".

@150balbes is doing great work on Amlogic boxes but unfortunately not in an "upstream" way. Downloads are stored on Yandex, a Russian site, which sometimes gives: "Download limit exceeded. You can save the folder to Yandex.Disk and download it from there."

So ideally we could find a way to boot Debian or Ubuntu proper without Armbian.

## LED display

The box has a LED display that can show messages such as "boot" (apparently written there by the bootloader) and time, LAN status, etc. (written there by the system). There is a kernel driver and userland tool for FD628 and similar compatible LED controller drivers available at https://github.com/LibreELEC/linux_openvfd. LibreELEC has integrated it, there is a configuration file specifically for the TX92 at https://github.com/LibreELEC/linux_openvfd/blob/master/conf/meson-gxm-tx92.conf.

## Opening the device

Under three out of the four rubber feet there are scres which need to be removed before the housing can be opened.

## Trying to run own U-Boot

Not sure but this whole `s905_autoscript` thing may come from @150balbes Armbian. In any case, if there is a file called `u-boot.ext` then it is loaded and executed. At that point, however, everything stalls... at least when using the `u-boot.sd` file that comes with @150balbes Armbian.

```
reading s905_autoscript
1654 bytes read in 4 ms (403.3 KiB/s)
## Executing script at 01020000
start amlogic old u-boot
## Error: "bootfromsd" not defined
reading boot_android
** Unable to read file boot_android **
** Bad device usb 0 **
reading u-boot.ext
709768 bytes read in 43 ms (15.7 MiB/s)
## Starting application at 0x01000000 ...
```

Where can we get a precompiled EFI enabled U-Boot from?

Answer: openSUSE has a Khadas VIM2 U-Boot which can boot this board, but the TX92 boot screen is garbled.

TX92 (s912) can boot this U-Boot, e.g., by placing it as `u-boot.ext` file in a @150balbes BOOT partition:

https://build.opensuse.org/package/binaries/hardware:boot/u-boot:khadas-vim2/openSUSE_Factory_ARM


```
reading u-boot.ext
625673 bytes read in 38 ms (15.7 MiB/s)
## Starting application at 0x01000000 ...


U-Boot 2020.04 (Apr 17 2020 - 12:05:54 +0000) khadas-vim2

Model: Khadas VIM2
SoC:   Amlogic Meson GXM (S912) Revision 22:a (82:2)
DRAM:  2 GiB
MMC:   mmc@70000: 0, mmc@72000: 1, mmc@74000: 2
In:    serial
Out:   serial
Err:   serial
[BL31]: tee size: 0
[BL31]: tee size: 0
Net:   eth0: ethernet@c9410000
Hit any key to stop autoboot:  0 
=> 
```

It has a command `usbboot`, and it has a command `bootefi`.

But: __TX92 boot screen is garbled, HDMI output thereafter is fine. USB booting probably not working from this board yet because storage device is not detected.__

```
=> usb reset
resetting USB...
Bus dwc3@c9000000: Register 3000140 NbrPorts 3
Starting the controller
USB XHCI 1.00
scanning bus dwc3@c9000000 for devices... Device not responding to set address.

      USB device not accepting new address (error=80000000)
1 USB Device(s) found
       scanning usb for storage devices... 0 Storage Device(s) found
=> usb info 
1: Hub,  USB Revision 3.0
 - U-Boot XHCI Host Controller 
 - Class: Hub
 - PacketSize: 512  Configurations: 1
 - Vendor: 0x0000  Product 0x0000 Version 1.0
   Configuration: 1
   - Interfaces: 1 Self Powered 0mA
     Interface: 0
     - Alternate Setting 0, Endpoints: 1
     - Class Hub
     - Endpoint 1 In Interrupt MaxPacket 8 Interval 255ms
```

The openSUSE wiki https://en.opensuse.org/HCL:Khadas_Vim2 mentions

> As of U-Boot v2019.07-rc4, booting directly from USB was not working.

Possibly this is still the case?
