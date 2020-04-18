# Tanix TX92

The Tanix TX92 features an Octacore 64-bit Amlogic s812 SOC with a T820 GPU. 

As of 4/2020, this GPU is said to play video smoother in a Linux web browser than most others. In our tests, YouTube video plays smooth in Chrome on @150balbes Armbian in a window, and "almost smooth" in fullscreen.

The Tanix TX92 is very well-built. Unlike with cheaper boxes, the PCB is mounted upward facing, hence the connectors are in the correct orientation.

## dtb

The box is apparently available in different memory configurations, e.g., 2/16 GB. So far it is not clear which dtb is 100% working. Using `meson-gxm-q200.dtb` the system boots but WLAN and Bluetooth are not working.
