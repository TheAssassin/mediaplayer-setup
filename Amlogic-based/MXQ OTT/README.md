# MXQ OTT

The MXQ OTT is a __32-bit__ Amlogic S805 SoC based media box. It ships with some totally out of date Android 4.

Most boxes ĉlaim to come with 1 GiB of RAM and 8 GiB of internal NAND flash, but it is not uncommon that in reality those boxes contain only 512 MB RAM which is shared between the CPU and the GPU. Some "fake" boxes even come with a hacked Android that displays 1 GB nevertheless.

__Note:__ As most Linux development for Amlogic is focused on __64-bit__ nowadays, it may be better to get one of those boxes, because software support is much better for 64-bit Amlogic ARM SoCs at this point.

## Supported alternative distributions

There are Armbian builds for those boxes that work very well. Most of them are made by third parties. Use at your own risk.

There is a special [LibreELEC](https://libreelec.tv) fork called [AlexELEC](https://github.com/AlexELEC/AE-AML) which has been tuned to work on these devices. Those images aren't necessarily trustworthy. You might not want to connect them to your home network. They use the Russian language by default; if you ever used Kodi, you will be able to change it to English (and possibly more languages if the box is connected to the Internet).

**TODO:** Build custom AlexELEC image with English as main language


## Booting alternative distributions

The box will by default boot from its internal NAND flash. To make it boot from SD, you might have to use the microswitch hidden inside the "AV" 3.5mm (1/8") jack socket. Hold it, then plug in the box. It should boot from the SD, provided the image you are using on the SD is prepared for those boxes (the U-Boot inside the box requires some Android style files layout, including a `dtb.img` etc.). You can release the switch when you see it's booting.


## Debugging

There's a UART port inside the box. You can connect to it with e.g., a UART USB adapter. The port shows the U-Boot and kernel boot messages. If there are any boot issues, you can see them on a serial terminal.


## Installing alternative distros to NAND

It's certainly possible to install custom distributions to the internal NAND, so you don't have to boot from SD. **You should back up all internal devices (`/dev/boot` and a few others).**

Some special distros like AlexELEC (and likely LibreELEC) come with a script called `installtointernal` which does the heavy lifting. If it doesn't work, try running a second time.

The NAND might be of questionable quality. There's been reports about file loss. A good SD card might last longer. There is no credible evidence for both, though.

At least in one case, we were succesfull in flashing AlexELEC to the internal NAND, and are happy with the results. Be sure to make a full backup of the internal NAND first, as you may be unable to find firmware that matches your exact variant of the hardware on the net.
