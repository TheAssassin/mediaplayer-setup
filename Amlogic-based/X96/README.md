#  X96 (non-mini)

Content from https://gist.github.com/probonopd/d4f0a3c7105b8378bc10eebe7f2d7de9 to be transferred here

## Serial port

A 3d printed pogo pin fixture has been used to access the tiny serial port test points using P50-B1 0.68mm pogo pins.

## Chainloading upstream U-Boot

__Possibly__ S905X systems can be booted using https://build.opensuse.org/package/binaries/hardware:boot/u-boot:khadas-vim/openSUSE_Factory_ARM, see https://en.opensuse.org/HCL:Khadas_Vim.

To do this, place the u-boot.bin file from openSUSE into the BOOT partition of @150balbes Armbian, and call it `u-boot.ext`. Watch from a serial console what is going on.

This still needs to be verified.

If it is working, we may try to load openSUSE ISO using `efiboot` and `grub.efi`...
