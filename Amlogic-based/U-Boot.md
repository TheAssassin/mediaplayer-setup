# U-Boot for Amlogic

U-Boot is the bootloader used in Amlogic products. The version shipped in most Amlogic-based retail products is outdated (e.g., does not have EFI functionality), hence it may be desired to use a newer U-Boot.

## Amlogic U-Boot Custodian Tree

The [Amlogic U-Boot Custodian Tree](https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic) is a branch of the official (upstream) U-Boot project in which the Amlogic-related work is happening. So if we are interested in following upstream work closely, then we need to use that branch.

As of April 2020, https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic/-/tree/u-boot-amlogic/board%2Famlogic had support for the following Amlogic reference boards:

* p200 (Amlogic S905, e.g., NanoPi K2, Odroid C2)
* p201 (Amlogic S905)
* p212 (Amlogic S905X, e.g., LibreTech AC, LibreTech CC)
* q200 (Amlogic S912, e.g., Khadas VIM2)
* s400 (Amlogic A113DX)
* u200 (Amlogic S905D2)
* w400 (tbd)

__It seems like there is no U-Boot configuration for Amlogic S905W__  (which is used in retail products with especially good price-performance ratio such as X96 mini). How to solve this?
