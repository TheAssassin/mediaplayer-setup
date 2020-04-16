# Linux on TV boxes setup and hacking guides

Nowadays there's tons of inexpensive embedded media player ("TV box") hardware available. For under 30 EUR, you can get tiny player modules capable of decoding 4K material (at 30fps at most, of course).

These modules frequently ship with some outdated and highly customized Android. Luckily, many of those systems can run Linux distributions, both media consumotion centered ones (e.gl, LibreELEC, OpenELEC) and general-purpose/productiviy ones (Debian, Arch, openSUSE, etc.)

For some of the system-on-chip reference boards (e.g., Amlogic based ones), efforts are underway to get them supported in mainline U-Boot and in the mainline Linux kernel, which should enable us to run Linux-based systems on those boxes with decreasing need for hardware-specific shenanigans.

This repository contains some setup notes taken while trying to set those up with better distributions. Most of the time successfully, sometimes not, often with some issues which may be resolved.


## Contributions welcome!

If you went through getting such a device running with e.g., Kodi, please consider sharing your experiences by sending a PR.

If you notice errors, differences, missing details etc., please consider sending a pull request with fixes.
