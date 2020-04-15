# CoreELEC on X96 mini

[CoreELEC](https://coreelec.org/) is a fork of [LibreELEC](https://libreelec.tv/) specifically optimized for Amlogic-SoC-based devices. The X96 mini is officially supported (it goes by the codename `gxl_p281_1g` resp. `gxl_p281_2g`, depending on the RAM size).

The released 9.2.1 image has turned out not to perform very well (might have to do with using the wrong DTB image). A nightly image has worked perfectly well.

This document provides a simple guide showing how to set up CoreELEC on an X96 mini with 1G/8G.


## Flashing firmware

You need an SD card with at least 1 GiB of space. 2 GiB or more is recommended. You should use *at least* Class 10.

Download the image you want to try. The release build is available [here](https://coreelec.org/#download), nightly images are available [here](https://relkai.coreelec.org/). The image tested here is [this one](https://relkai.coreelec.org/CoreELEC-Amlogic.arm-9.2-nightly_20200408-Generic.img.gz), SHA256 hash sum is `62224b962a458a168e382ffd71a948a675a3b281dd4e5570ee26523834bf6332`.

Just flash it with any method directly on the device. It contains two partitions (one called `COREELEC`, one called `STORAGE`).

Once flashed, mount `COREELEC` and copy the right DTB image to the root directory:

```sh
sudo cp device_trees/gxl_p281_1g.dtb dtb.img
```

You need to perform further operations on `STORAGE`, but first the image wants to resize itself to the entire SD card (there's a file on `STORAGE` indicating this).


## First time boot

Boot the device from the SD card. It might work automatically, but you can also hold the microswitch inside the AV port with a non-conducting material, e.g., a wooden toothpick you cut off flatly.

It will boot, resize itself, then reboot into CoreELEC. You can either turn it off again now or perform the initial setup. Beware you need a mouse for that, the RC doesn't work yet.


## Add missing RC keymap

There's a [Dropbox share](https://www.dropbox.com/sh/w60gx2c66rpmb4e/AAAVeDersy7MJFCESRCAEGcVa?dl=0) containing keymaps for a large variety of devices. We've found the [X96](https://www.dropbox.com/sh/w60gx2c66rpmb4e/AAAVeDersy7MJFCESRCAEGcVa?dl=0&preview=X96.zip) (that's a sort of slightly larger device, similar to the [MXQ OTT](../MXQ OTT/) keymaps work reasonably well.

You can find a copy of the required files in this directory.

Open the `STORAGE` partition. Copy `rc_maps.cfg` to `.config/`. This file then includes the `X96` file, so you have to copy that one into `.config/rc_keymaps/`.

That's it, now the remote control should be working fine with CoreELEC/Kodi.

**Note:** You do not have to perform this "offline" on your computer, you can also do the modifications via SSH. The partition is mounted as `/storage`.


## Installing to NAND

Installing to NAND is not possible at the moment. CoreELEC's `installtointernal` script expects a certain device/partition layout. SD card works just fine, though.


## Unresolved problems

- The stable image has suffered from severe performance issues. Usable with a *lot* of patience. Nightly has worked fine, so perhaps the next release works better?
- The "house" key (home button) does not work as intended, it does not open the home menu but instead opens the media info (like the button on the lower left of the arrow keys). This seems to be a CoreELEC issue rather than a keymap issue, though, as the exact same keymap works normally on a X96 (larger model) with an unofficial LibreELEC build.


