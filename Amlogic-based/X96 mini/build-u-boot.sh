#!/bin/bash -ex

# Known to work on Ubuntu 18.04.4 LTS

# This script is following the instructions from
# https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic/-/blob/u-boot-amlogic/board/amlogic/p212/README.p212

# undocumented preparation
# ========================

sudo apt-get -y install git lib32ncurses5 lib32z1 bison lib32stdc++6 flex gcc-aarch64-linux-gnu g++-aarch64-linux-gnu 

# Clean up from previous runs if needed
# sudo rm -rf amlogic-u-boot/ u-boot-amlogic/ /opt/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux

# u-boot compilation
# ==================

git clone --depth 1 https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic
cd u-boot-amlogic

export ARCH=arm
# export CROSS_COMPILE=aarch64-none-elf- # WRONG! This seems to be WRONG in https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic/-/blob/u-boot-amlogic/board/amlogic/p212/README.p212
export CROSS_COMPILE=aarch64-linux-gnu- # WORKS!

make p212_defconfig
make -j$(nproc)

pushd . # Remember this directory, we will come back here later

###############################################################################################################
# NOTE: If you get those errors:
# /bin/sh: 1: aarch64-none-elf-gcc: not found
# make: aarch64-none-elf-gcc: Command not found
# /bin/sh: 1: aarch64-none-elf-gcc: not found
# then you need to enable 32-bit support on the build system:
# sudo apt-get install lib32ncurses5 lib32z1
# Why are they using 32-bit binaries rather than 64-bit ones?
###############################################################################################################

###############################################################################################################
# NOTE: If you get those errors:
# *** Your GCC is older than 6.0 and is not supported
# arch/arm/config.mk:66: recipe for target 'checkgcc6' failed
# make: *** [checkgcc6] Error 1
# then you need a newer one than the one documented in
# https://gitlab.denx.de/u-boot/custodians/u-boot-amlogic/-/blob/u-boot-amlogic/board/amlogic/p212/README.p212
# which is used below
###############################################################################################################

# Image creation
# ==============

cd ..

wget https://releases.linaro.org/archive/13.11/components/toolchain/binaries/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux.tar.xz
wget https://releases.linaro.org/archive/13.11/components/toolchain/binaries/gcc-linaro-arm-none-eabi-4.8-2013.11_linux.tar.xz
tar xvfJ gcc-linaro-aarch64-none-elf-4.8-2013.11_linux.tar.xz
tar xvfJ gcc-linaro-arm-none-eabi-4.8-2013.11_linux.tar.xz
export PATH=$PWD/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux/bin:$PWD/gcc-linaro-arm-none-eabi-4.8-2013.11_linux/bin:$PATH
export CROSS_COMPILE=aarch64-none-elf-
git clone --depth 1 https://github.com/BayLibre/u-boot.git -b n-amlogic-openlinux-20170606 amlogic-u-boot
cd amlogic-u-boot
make gxl_p212_v1_defconfig

# Undocumented workaround for
# /bin/sh: 1: /bin/sh: 1: /opt/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux/bin/aarch64-none-elf-gcc:
# not found /opt/gcc-linaro-aarch64-none-elf-4.8-2013.11_linux/bin/aarch64-none-elf-gcc: not found
sudo ln -s $(readlink -f ../gcc-linaro-aarch64-none-elf-4.8-2013.11_linux) /opt/

make -j$(nproc)

###############################################################################################################
# NOTE: If you have checked out the amlogic git inside the custodians git, 
# then compilation stops here with the following errors. This is left here for people who
# might be running into this issue.
#
# In file included from ./../include/libfdt_env.h:12:0,
#                  from <command-line>:0:
# ../../tools/../include/linux/../../scripts/dtc/libfdt/libfdt_env.h:47:45: error: expected ‘)’ before ‘x’
#  static inline uint32_t fdt32_to_cpu(fdt32_t x)
#                                             ^
# ./../include/compiler.h:66:6: note: in definition of macro ‘uswap_32’
#   ((((x) & 0xff000000) >> 24) | \
#       ^
# ./../include/libfdt_env.h:21:26: note: in expansion of macro ‘be32_to_cpu’
#  #define fdt32_to_cpu(x)  be32_to_cpu(x)
#                           ^~~~~~~~~~~
# ../../tools/../include/linux/../../scripts/dtc/libfdt/libfdt_env.h:47:24: note: in expansion of macro ‘fdt32_to_cpu’
#  static inline uint32_t fdt32_to_cpu(fdt32_t x)
#                         ^~~~~~~~~~~~
# ./../include/compiler.h:66:9: error: expected ‘)’ before ‘&’ token
#   ((((x) & 0xff000000) >> 24) | \
#
###############################################################################################################

export FIPDIR=$PWD/fip

popd # Come back to the custodian directory

mkdir fip

cp $FIPDIR/gxl/bl2.bin fip/
cp $FIPDIR/gxl/acs.bin fip/
cp $FIPDIR/gxl/bl21.bin fip/
cp $FIPDIR/gxl/bl30.bin fip/
cp $FIPDIR/gxl/bl301.bin fip/
cp $FIPDIR/gxl/bl31.img fip/
cp u-boot.bin fip/bl33.bin

$FIPDIR/blx_fix.sh \
	fip/bl30.bin \
	fip/zero_tmp \
	fip/bl30_zero.bin \
	fip/bl301.bin \
	fip/bl301_zero.bin \
	fip/bl30_new.bin \
	bl30

python2.7 $FIPDIR/acs_tool.pyc fip/bl2.bin fip/bl2_acs.bin fip/acs.bin 0 # NOTE: python2 is needed

$FIPDIR/blx_fix.sh \
	fip/bl2_acs.bin \
	fip/zero_tmp \
	fip/bl2_zero.bin \
	fip/bl21.bin \
	fip/bl21_zero.bin \
	fip/bl2_new.bin \
	bl2

$FIPDIR/gxl/aml_encrypt_gxl --bl3enc --input fip/bl30_new.bin
$FIPDIR/gxl/aml_encrypt_gxl --bl3enc --input fip/bl31.img
$FIPDIR/gxl/aml_encrypt_gxl --bl3enc --input fip/bl33.bin
$FIPDIR/gxl/aml_encrypt_gxl --bl2sig --input fip/bl2_new.bin --output fip/bl2.n.bin.sig
$FIPDIR/gxl/aml_encrypt_gxl --bootmk \
		--output fip/u-boot.bin \
		--bl2 fip/bl2.n.bin.sig \
		--bl30 fip/bl30_new.bin.enc \
		--bl31 fip/bl31.img.enc \
		--bl33 fip/bl33.bin.enc

ls -lh ./fip/u-boot*.bin
