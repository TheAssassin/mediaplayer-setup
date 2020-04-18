# Tanix TX92

The Tanix TX92 features an Octacore 64-bit Amlogic s812 SOC with a T820 GPU. 

As of 4/2020, this GPU is said to play video smoother in a Linux web browser than most others. In our tests, YouTube video plays smooth in Chrome on @150balbes Armbian in a window, and "almost smooth" in fullscreen.

The Tanix TX92 is very well-built. Unlike with cheaper boxes, the PCB is mounted upward facing, hence the connectors are in the correct orientation.

## Stock ROM Android

The Android in the stock ROM is pre-rooted. Using Termux (installed from https://f-droid.org/), the `su` command conveniently works out of the box.

## dtb

The box is apparently available in different memory configurations, e.g., 2/16 GB. So far it is not clear which dtb is 100% working. Using `meson-gxm-q200.dtb` the system boots but WLAN and Bluetooth are not working.

## Running Desktop Linux

### @150balbes Armbian

@150balbes "Single Armbian image for RK + AML + AW" from https://forum.armbian.com/topic/12162-single-armbian-image-for-rk-aml-aw/ works on this box. Using `meson-gxm-q200.dtb` the system boots but WLAN and Bluetooth are not working.

The Armbian project does not want to support TV boxes nor the "Single Armbian image for RK + AML + AW".

@150balbes is doing great work on Amlogic boxes but unfortunately not in an "upstream" way. Downloads are stored on Yandex, a Russian site, which sometimes gives: "Download limit exceeded. You can save the folder to Yandex.Disk and download it from there."

So ideally we could find a way to boot Debian or Ubuntu proper without Armbian.
