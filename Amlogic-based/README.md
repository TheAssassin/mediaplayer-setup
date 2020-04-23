# Amlogic SOCs

## Linux support

### Linux Meson

The [Linux Meson](http://linux-meson.com/doku.php) project is there to bring Amlogic SoC support into the mainline Linux kernel.

As of 4/2020 this is in a bootable state, although not all distributions are using the mainline kernel yet. The Linux Meson project works "upstream". This means that there are no downloadable images, but the idea is that Linux distributions will pick up the software sooner or later.

Unfortunately, the Linux Meson project's documentation on how to boot into e.g., Debian using the mainline kernel is not very clear. Any insights appreciated.

### LibreELEC, CoreELEC, AlexELEC

LibreELEC, CoreELEC, AlexELEC are media center focused distributions with builds for Armlogic systems. They ship with KODI.

### Armbian

Armbian is a project to run Debian and/or Ubuntu on ARM-based systems. Unfortunately they don't want to support retail products, only developer boards. Despite its name, this is not an official Debian project.

### @150balbes Armbian

@150balbes is a developer who is doing special Armbian builds for Amlogic-based retail products ("TV boxes"). Despite its name, this is not an official Armbian project and the Armbian project refuses to support his work.

### Debian, openSUSE, Fedora, Ubuntu,...

Those "mainstream" distributions are increasingly adding aarch64 builds and partly even ISO images. However, none of them are specifically built for Amlogic-based systems, and hence do not boot out of the box (possibly unless a EFI-capable U-Boot is used, to be verified).

## Booting

Booting Amlogic SOCs requires, besides a Linux kernel and initrd, a bootloader (an older version of U-Boot is normally preinstalled on the boxes), and a dtb file matching to the exact hardware device (box) you are using.

### EFI booting

A newer approach to booting is using EFI. The Amlogic Meson project has been working on bringing EFI support for Amlogic SoCs into mainline U-Boot. This is said to have the advantage of being able to boot e.g., stock openSUSE ISOs without the need for manually setting up a boot partition.

Seemingly, as long as there is a bootloader installed to the internal memory of the device, the device will ignore bootloaders on SD card or USB (please correct if this is wrong). So there is apparently no good way to test a new U-Boot build without having to mess with the stock bootloader.

### USB booting

Unlike most Raspberry Pis, Amlogic devices can boot not only from SD card, but also from USB. This has been verified on a X96 mini and a Tanix TX92 by attaching a USB card reader and putting the SD card into that USB card reader. It still boots, even if the card reader is attached via a USB hub (a feat that even some Intel desktop machines don't manage to do).

## Booting generic kernels in 64-bit Amlogic devices

__Work in progress. Contributions welcome.__

Amlogic systems are supposed to be able to boot generic "mainline" kernels. If we use a kernel from a rolling release distribution such as openSUSE Tumbleweed or Debian sid, we should be able to run the latest kernel on Amlogic devices.

@150balbes Armbian uses a `boot.cmd` compiled into a `boot.scr`  and `s905_autoscript.cmd` compiled into a `s905_autoscript` that uses `uEnv.txt` to configure boot parameters. At least in those scripts it is mandatory to have an `uInitrd`, otherwise it will not proceed to run the boot command.

### Trying to run mainline kernel from kernelci.org

kernelci.org is the closest thing to "upstream-packaged binaries" of the Linux kernel.

https://kernelci.org/soc/amlogic/ has known working kernels for many Amlogic devices.

__How can we boot them?__

It seems that they are using Linaro LAVA https://git.lavasoftware.org/lava/lava which roughly does:
* Download kernel
* Download kernel modules
* Download initrd
* Umpack initrd and put kernel modules inside
* Repack initrd
* Run kernel trough mkimage
* Run initrd through mkimage
* Communicate with the device over serial, enter U-Boot there
* Cause U-Boot to load the files over Ethernet (TFTP) and boot them

> LAVA is a continuous integration system for deploying operating systems onto physical and virtual hardware for running tests. Tests can be simple boot testing, bootloader testing and system level testing, although extra hardware may be required.

This seems to be the code that does it: https://git.lavasoftware.org/lava/lava/-/blob/master/lava_dispatcher/actions/deploy/apply_overlay.py

## Booting generic Linux distributions

### Generate uInitrd

@150balbes Armbian automatically converts initrd to  `uInitrd` as required by running [this](https://github.com/150balbes/Build-Armbian/blob/master/packages/bsp/common/etc/initramfs/post-update.d/99-uboot) code:

```
mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /boot/initrd.img-* /boot/uInitrd
```

#### Trying openSUSE

Are we able to take an openSUSE Tumbleweed kernel and ramdisk and boot them on an Amlogic device?

The first issue is that the openSUSE initrd seems to be in a different format:

```
# Ubuntu
me@host:~$ file /boot/initrd.img-*
/boot/initrd.img-4.18.0-15-generic: ASCII cpio archive (SVR4 with no CRC)

# openSUSE
me@host:~$ sudo mount 'openSUSE-Tumbleweed-XFCE-Live-aarch64-Snapshot20200411-Media.iso' /mnt
me@host:~$ sudo file '/mnt/boot/aarch64/loader/initrd'
/mnt/boot/aarch64/loader/initrd: XZ compressed data
```

Does this matter? Let's try t o put the openSUSE kernel and initrd onto the `BOOT` partition of a @150balbes Armbian system:

```
me@host:~$ sudo mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d /mnt/boot/aarch64/loader/initrd '/media/me/BOOT/uInitrd'

me@host:~$ sudo cp /mnt/boot/aarch64/loader/linux '/media/me/BOOT/zImage'
```

When trying to boot, the boot stalls at the Amlogic boot screen.

What happens if we try to run the openSUSE kernel with the @150balbes Armbian ramdisk? **It boots!** So we know that the Amlogic device can boot a openSUSE Tumbleweed kernel but we still need to do some work to get the openSUSE ramdisk loaded.

Maybe our mkimage command is wrong?

Let's try to extract the XZ initrd and recompress it as a gz one:

```
me@host:~$ sudo su
me@host:~$ mkdir initrd && cd initrd
me@host:~$ xz -dc < /mnt/boot/aarch64/loader/initrd | cpio -idmv
me@host:~$ find . | cpio -o -c | gzip -9 > ../initrdfile
cd ..
me@host:~$ sudo mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d initrdfile '/media/me/BOOT/uInitrd'
```

**It boots!** So we know that the Amlogic device can boot a openSUSE Tumbleweed kernel and a repacked openSUSE Tumbleweed initrd.

Without an openSUSE live image it cannot boot a root fs obviously. So we need to transfer that over, too.  And we need to change the kernel arguments in uEnv.txt. So copying the `LiveOS` directory to the `ROOTFS` partition. (Not clear whether the openSUSE ramdisk can boot it from there...)

```
append=root=live:LABEL=ROOTFS rd.live.image rd.live.overlay.persistent rd.live.overlay.cowfs=ext4
```

We see `RAMDISK: incomplete write (16269 != 27512)`. it is unclear whether this is the root cause why we end up with

here are the available partitions: ram0 - ram15, mmcblk1, 

`VFS: Unable to mount root fs on unknown-block(0,0)`

The openSUSE initrd is huge, whereas the @150balbes Armbian one is just around 15 MB.

Is this the culprit?

Do we have to change something in U-Boot?

Here is the boot log:

```
Hit Enter or space or Ctrl+C key to stop autoboot -- :  1 
card in
init_part() 278: PART_TYPE_DOS
[mmc_init] mmc init success
Device: SDIO Port B
Manufacturer ID: 1b
OEM: 534d
Name: EB1QT 
Tran Speed: 50000000
Rd Block Len: 512
SD version 3.0
High Capacity: Yes
Capacity: 29.8 GiB
mmc clock: 40000000
Bus Width: 4-bit
reading s905_autoscript
1654 bytes read in 4 ms (403.3 KiB/s)
## Executing script at 01020000
start amlogic old u-boot
## Error: "bootfromsd" not defined
reading boot_android
** Unable to read file boot_android **
** Bad device usb 0 **
reading u-boot.ext
** Unable to read file u-boot.ext **
** Bad device usb 0 **
reading uEnv.txt
1498 bytes read in 4 ms (365.2 KiB/s)
mac=06:41:71:xx:xx:xx
reading /zImage
27798016 bytes read in 1512 ms (17.5 MiB/s)
reading /uInitrd
25994817 bytes read in 1416 ms (17.5 MiB/s)
reading /dtb/amlogic/meson-gxm-q200.dtb
29783 bytes read in 10 ms (2.8 MiB/s)
## Error: "aadmac" not defined
libfdt fdt_path_offset() returned FDT_ERR_NOTFOUND
[rsvmem] fdt get prop fail.
## Loading init Ramdisk from Legacy Image at 13000000 ...
   Image Name:   uInitrd
   Image Type:   AArch64 Linux RAMDisk Image (uncompressed)
   Data Size:    25994753 Bytes = 24.8 MiB
   Load Address: 00000000
   Entry Point:  00000000
   Verifying Checksum ... OK
load dtb from 0x1000000 ......
      Amlogic multi-dtb tool
      Single dtb detected
## Flattened Device Tree blob at 01000000
   Booting using the fdt blob at 0x1000000
libfdt fdt_path_offset() returned FDT_ERR_NOTFOUND
[rsvmem] fdt get prop fail.
   Loading Ramdisk to 725d6000, end 73ea0601 ... OK
   Loading Device Tree to 000000001fff5000, end 000000001ffff456 ... OK
fdt_instaboot: no instaboot image
Starting kernel ...
uboot time: 6409296 us
[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
[    0.000000] Linux version 5.6.2-arm-64 (root@vbox) (gcc version 8.3.0 (GNU Toolchain for the A-profile Architecture 8.3-2019.03 (arm-rel-8.36))) #20.05.1 SMP PREEMPT Wed Apr 8 15:18:14 MSK 2020
[    0.000000] Machine model: Amlogic Meson GXM (S912) Q200 Development Board
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] Reserved memory: created CMA memory pool at 0x0000000062400000, size 256 MiB
[    0.000000] OF: reserved mem: initialized node linux,cma, compatible id shared-dma-pool
[    0.000000] earlycon: meson0 at MMIO 0x00000000c81004c0 (options '115200n8')
[    0.000000] printk: bootconsole [meson0] enabled
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv0.2 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: Trusted OS migration not required
[    0.000000] percpu: Embedded 22 pages/cpu s51160 r8192 d30760 u90112
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] CPU features: detected: ARM erratum 845719
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 470336
[    0.000000] Kernel command line: root=live:LABEL=ROOTFS rd.live.image rd.shell rd.debug log_buf_len=1M console=ttyAML0,115200n8 console=tty0 no_console_suspend console mac=06:41:71:xx:xx:xx
[    0.000000] printk: log_buf_len: 1048576 bytes
[    0.000000] printk: early log buf free: 260240(99%)
[    0.000000] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.000000] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes, linear)
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0x3bfff000-0x3ffff000] (64MB)
[    0.000000] Memory: 1488732K/1911808K available (15484K kernel code, 1482K rwdata, 6496K rodata, 3648K init, 934K bss, 160932K reserved, 262144K cma-reserved)
[    0.000000] random: get_random_u64 called from cache_random_seq_create+0x7c/0x150 with crng_init=0
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] rcu: Preemptible hierarchical RCU implementation.
[    0.000000] 	Tasks RCU enabled.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] GIC: Using split EOI/Deactivate mode
[    0.000000] irq_meson_gpio: 110 to 8 gpio interrupt mux initialized
[    0.000000] arch_timer: cp15 timer(s) running at 24.00MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x588fe9dc0, max_idle_ns: 440795202592 ns
[    0.000004] sched_clock: 56 bits at 24MHz, resolution 41ns, wraps every 4398046511097ns
[    0.008502] Console: colour dummy device 80x25
[    0.012522] printk: console [tty0] enabled
[    0.016630] printk: bootconsole [meson0] disabled
[    0.000000] Booting Linux on physical CPU 0x0000000000 [0x410fd034]
[    0.000000] Linux version 5.6.2-arm-64 (root@vbox) (gcc version 8.3.0 (GNU Toolchain for the A-profile Architecture 8.3-2019.03 (arm-rel-8.36))) #20.05.1 SMP PREEMPT Wed Apr 8 15:18:14 MSK 2020
[    0.000000] Machine model: Amlogic Meson GXM (S912) Q200 Development Board
[    0.000000] efi: Getting EFI parameters from FDT:
[    0.000000] efi: UEFI not found.
[    0.000000] Reserved memory: created CMA memory pool at 0x0000000062400000, size 256 MiB
[    0.000000] OF: reserved mem: initialized node linux,cma, compatible id shared-dma-pool
[    0.000000] earlycon: meson0 at MMIO 0x00000000c81004c0 (options '115200n8')
[    0.000000] printk: bootconsole [meson0] enabled
[    0.000000] psci: probing for conduit method from DT.
[    0.000000] psci: PSCIv0.2 detected in firmware.
[    0.000000] psci: Using standard PSCI v0.2 function IDs
[    0.000000] psci: Trusted OS migration not required
[    0.000000] percpu: Embedded 22 pages/cpu s51160 r8192 d30760 u90112
[    0.000000] Detected VIPT I-cache on CPU0
[    0.000000] CPU features: detected: ARM erratum 845719
[    0.000000] Built 1 zonelists, mobility grouping on.  Total pages: 470336
[    0.000000] Kernel command line: root=live:LABEL=ROOTFS rd.live.image rd.shell rd.debug log_buf_len=1M console=ttyAML0,115200n8 console=tty0 no_console_suspend console mac=06:41:71:xx:xx:xx
[    0.000000] printk: log_buf_len: 1048576 bytes
[    0.000000] printk: early log buf free: 260240(99%)
[    0.000000] Dentry cache hash table entries: 262144 (order: 9, 2097152 bytes, linear)
[    0.000000] Inode-cache hash table entries: 131072 (order: 8, 1048576 bytes, linear)
[    0.000000] mem auto-init: stack:off, heap alloc:off, heap free:off
[    0.000000] software IO TLB: mapped [mem 0x3bfff000-0x3ffff000] (64MB)
[    0.000000] Memory: 1488732K/1911808K available (15484K kernel code, 1482K rwdata, 6496K rodata, 3648K init, 934K bss, 160932K reserved, 262144K cma-reserved)
[    0.000000] random: get_random_u64 called from cache_random_seq_create+0x7c/0x150 with crng_init=0
[    0.000000] SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=8, Nodes=1
[    0.000000] rcu: Preemptible hierarchical RCU implementation.
[    0.000000] 	Tasks RCU enabled.
[    0.000000] rcu: RCU calculated value of scheduler-enlistment delay is 25 jiffies.
[    0.000000] NR_IRQS: 64, nr_irqs: 64, preallocated irqs: 0
[    0.000000] GIC: Using split EOI/Deactivate mode
[    0.000000] irq_meson_gpio: 110 to 8 gpio interrupt mux initialized
[    0.000000] arch_timer: cp15 timer(s) running at 24.00MHz (phys).
[    0.000000] clocksource: arch_sys_counter: mask: 0xffffffffffffff max_cycles: 0x588fe9dc0, max_idle_ns: 440795202592 ns
[    0.000004] sched_clock: 56 bits at 24MHz, resolution 41ns, wraps every 4398046511097ns
[    0.008502] Console: colour dummy device 80x25
[    0.012522] printk: console [tty0] enabled
[    0.016630] printk: bootconsole [meson0] disabled
[    0.021389] Calibrating delay loop (skipped), value calculated using timer frequency.. 48.00 BogoMIPS (lpj=96000)
[    0.021408] pid_max: default: 32768 minimum: 301
[    0.021546] LSM: Security Framework initializing
[    0.021603] SELinux:  Initializing.
[    0.021674] *** VALIDATE selinux ***
[    0.021730] Mount-cache hash table entries: 4096 (order: 3, 32768 bytes, linear)
[    0.021751] Mountpoint-cache hash table entries: 4096 (order: 3, 32768 bytes, linear)
[    0.021815] *** VALIDATE tmpfs ***
[    0.022241] *** VALIDATE proc ***
[    0.022462] *** VALIDATE cgroup ***
[    0.022475] *** VALIDATE cgroup2 ***
[    0.053442] rcu: Hierarchical SRCU implementation.
[    0.063697] EFI services will not be available.
[    0.069493] smp: Bringing up secondary CPUs ...
[    0.101726] Detected VIPT I-cache on CPU1
[    0.101778] CPU1: Booted secondary processor 0x0000000001 [0x410fd034]
[    0.133765] Detected VIPT I-cache on CPU2
[    0.133810] CPU2: Booted secondary processor 0x0000000002 [0x410fd034]
[    0.165817] Detected VIPT I-cache on CPU3
[    0.165859] CPU3: Booted secondary processor 0x0000000003 [0x410fd034]
[    0.197893] Detected VIPT I-cache on CPU4
[    0.197949] CPU4: Booted secondary processor 0x0000000100 [0x410fd034]
[    0.229912] Detected VIPT I-cache on CPU5
[    0.229940] CPU5: Booted secondary processor 0x0000000101 [0x410fd034]
[    0.261966] Detected VIPT I-cache on CPU6
[    0.261992] CPU6: Booted secondary processor 0x0000000102 [0x410fd034]
[    0.294023] Detected VIPT I-cache on CPU7
[    0.294049] CPU7: Booted secondary processor 0x0000000103 [0x410fd034]
[    0.294137] smp: Brought up 1 node, 8 CPUs
[    0.294262] SMP: Total of 8 processors activated.
[    0.294274] CPU features: detected: 32-bit EL0 Support
[    0.294286] CPU features: detected: CRC32 instructions
[    0.307999] CPU: All CPU(s) started at EL2
[    0.308065] alternatives: patching kernel code
[    0.309279] devtmpfs: initialized
[    0.314665] Registered cp15_barrier emulation handler
[    0.314697] Registered setend emulation handler
[    0.314712] KASLR disabled due to lack of seed
[    0.315086] clocksource: jiffies: mask: 0xffffffff max_cycles: 0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.315121] futex hash table entries: 2048 (order: 5, 131072 bytes, linear)
[    0.321770] xor: measuring software checksum speed
[    0.358014]    8regs     :  2375.000 MB/sec
[    0.398048]    32regs    :  2724.000 MB/sec
[    0.438086]    arm64_neon:  2400.000 MB/sec
[    0.438097] xor: using function: 32regs (2724.000 MB/sec)
[    0.438158] pinctrl core: initialized pinctrl subsystem
[    0.438881] thermal_sys: Registered thermal governor 'step_wise'
[    0.439180] DMI not present or invalid.
[    0.439730] NET: Registered protocol family 16
[    0.443054] DMA: preallocated 256 KiB pool for atomic allocations
[    0.443102] audit: initializing netlink subsys (disabled)
[    0.443285] audit: type=2000 audit(0.436:1): state=initialized audit_enabled=0 res=1
[    0.444423] cpuidle: using governor ladder
[    0.444455] cpuidle: using governor menu
[    0.444803] hw-breakpoint: found 6 breakpoint and 4 watchpoint registers.
[    0.444962] ASID allocator initialised with 65536 entries
[    0.445697] Serial: AMBA PL011 UART driver
[    0.461133] HugeTLB registered 1.00 GiB page size, pre-allocated 0 pages
[    0.461155] HugeTLB registered 32.0 MiB page size, pre-allocated 0 pages
[    0.461169] HugeTLB registered 2.00 MiB page size, pre-allocated 0 pages
[    0.461181] HugeTLB registered 64.0 KiB page size, pre-allocated 0 pages
[    0.465415] cryptd: max_cpu_qlen set to 1000
[    0.542343] raid6: neonx8   gen()  2152 MB/s
[    0.610401] raid6: neonx8   xor()  1604 MB/s
[    0.678506] raid6: neonx4   gen()  2210 MB/s
[    0.746543] raid6: neonx4   xor()  1589 MB/s
[    0.814600] raid6: neonx2   gen()  2105 MB/s
[    0.882678] raid6: neonx2   xor()  1453 MB/s
[    0.950716] raid6: neonx1   gen()  1832 MB/s
[    1.018775] raid6: neonx1   xor()  1248 MB/s
[    1.086836] raid6: int64x8  gen()  1489 MB/s
[    1.154893] raid6: int64x8  xor()   783 MB/s
[    1.222954] raid6: int64x4  gen()  1670 MB/s
[    1.291011] raid6: int64x4  xor()   848 MB/s
[    1.359070] raid6: int64x2  gen()  1418 MB/s
[    1.427114] raid6: int64x2  xor()   741 MB/s
[    1.495178] raid6: int64x1  gen()  1055 MB/s
[    1.563245] raid6: int64x1  xor()   548 MB/s
[    1.563255] raid6: using algorithm neonx4 gen() 2210 MB/s
[    1.563266] raid6: .... xor() 1589 MB/s, rmw enabled
[    1.563276] raid6: using neon recovery algorithm
[    1.563842] fbcon: Taking over console
[    1.563886] ACPI: Interpreter disabled.
[    1.564985] iommu: Default domain type: Translated 
[    1.565262] vgaarb: loaded
[    1.565865] SCSI subsystem initialized
[    1.566261] usbcore: registered new interface driver usbfs
[    1.566309] usbcore: registered new interface driver hub
[    1.566384] usbcore: registered new device driver usb
[    1.566839] pps_core: LinuxPPS API ver. 1 registered
[    1.566853] pps_core: Software ver. 5.3.6 - Copyright 2005-2007 Rodolfo Giometti <giometti@linux.it>
[    1.566877] PTP clock support registered
[    1.566904] EDAC MC: Ver: 3.0.0
[    1.567906] FPGA manager framework
[    1.568008] Advanced Linux Sound Architecture Driver Initialized.
[    1.568543] NetLabel: Initializing
[    1.568559] NetLabel:  domain hash size = 128
[    1.568568] NetLabel:  protocols = UNLABELED CIPSOv4 CALIPSO
[    1.568625] NetLabel:  unlabeled traffic allowed by default
[    1.569094] clocksource: Switched to clocksource arch_sys_counter
[    1.569115] *** VALIDATE bpf ***
[    1.569383] VFS: Disk quotas dquot_6.6.0
[    1.569451] VFS: Dquot-cache hash table entries: 512 (order 0, 4096 bytes)
[    1.569586] FS-Cache: Loaded
[    1.569597] *** VALIDATE ramfs ***
[    1.569619] *** VALIDATE hugetlbfs ***
[    1.570008] pnp: PnP ACPI: disabled
[    1.575352] NET: Registered protocol family 2
[    1.575828] tcp_listen_portaddr_hash hash table entries: 1024 (order: 2, 16384 bytes, linear)
[    1.575876] TCP established hash table entries: 16384 (order: 5, 131072 bytes, linear)
[    1.575995] TCP bind hash table entries: 16384 (order: 6, 262144 bytes, linear)
[    1.576204] TCP: Hash tables configured (established 16384 bind 16384)
[    1.576363] UDP hash table entries: 1024 (order: 3, 32768 bytes, linear)
[    1.576419] UDP-Lite hash table entries: 1024 (order: 3, 32768 bytes, linear)
[    1.576670] NET: Registered protocol family 1
[    1.577118] RPC: Registered named UNIX socket transport module.
[    1.577136] RPC: Registered udp transport module.
[    1.577146] RPC: Registered tcp transport module.
[    1.577155] RPC: Registered tcp NFSv4.1 backchannel transport module.
[    1.577172] NET: Registered protocol family 44
[    1.577191] PCI: CLS 0 bytes, default 64
[    1.577389] Trying to unpack rootfs image as initramfs...
[    1.578510] rootfs image is not initramfs (incorrect cpio method used: use -H newc option); looks like an initrd
[    1.623562] Freeing initrd memory: 25384K
[    1.624626] hw perfevents: enabled with armv8_cortex_a53 PMU driver, 7 counters available
[    1.633029] Initialise system trusted keyrings
[    1.633279] workingset: timestamp_bits=46 max_order=19 bucket_order=0
[    1.639653] zbud: loaded
[    1.641280] squashfs: version 4.0 (2009/01/31) Phillip Lougher
[    1.641642] FS-Cache: Netfs 'nfs' registered for caching
[    1.642321] *** VALIDATE nfs ***
[    1.642403] *** VALIDATE nfs4 ***
[    1.642490] NFS: Registering the id_resolver key type
[    1.642523] Key type id_resolver registered
[    1.642534] Key type id_legacy registered
[    1.642552] nfs4filelayout_init: NFSv4 File Layout Driver Registering...
[    1.642567] Installing knfsd (copyright (C) 1996 okir@monad.swb.de).
[    1.644025] FS-Cache: Netfs 'cifs' registered for caching
[    1.644405] Key type cifs.spnego registered
[    1.644430] Key type cifs.idmap registered
[    1.644458] ntfs: driver 2.1.32 [Flags: R/W].
[    1.645263] JFS: nTxBlock = 8192, nTxLock = 65536
[    1.649967] SGI XFS with ACLs, security attributes, realtime, quota, no debug enabled
[    1.651559] *** VALIDATE xfs ***
[    1.651892] ocfs2: Registered cluster interface o2cb
[    1.652165] OCFS2 User DLM kernel interface loaded
[    1.653757] *** VALIDATE gfs2 ***
[    1.654118] gfs2: GFS2 installed
[    1.655251] aufs 5.x-rcN-20200302
[    1.671258] NET: Registered protocol family 38
[    1.671293] Key type asymmetric registered
[    1.671306] Asymmetric key parser 'x509' registered
[    1.671318] Asymmetric key parser 'pkcs8' registered
[    1.671385] Block layer SCSI generic (bsg) driver version 0.4 loaded (major 246)
[    1.671572] io scheduler mq-deadline registered
[    1.671589] io scheduler kyber registered
[    1.671814] io scheduler bfq registered
[    1.687912] soc soc0: Amlogic Meson GXM (S912) Revision 22:a (82:2) Detected
[    1.692503] Serial: 8250/16550 driver, 5 ports, IRQ sharing enabled
[    1.694672] Serial: AMBA driver
[    1.695082] c11084c0.serial: ttyAML6 at MMIO 0xc11084c0 (irq = 12, base_baud = 1500000) is a meson_uart
[    1.695259] serial serial0: tty port ttyAML6 registered
[    1.695515] c81004c0.serial: ttyAML0 at MMIO 0xc81004c0 (irq = 15, base_baud = 1500000) is a meson_uart
[    2.766120] printk: console [ttyAML0] enabled
[    2.785524] brd: module loaded
[    2.796585] loop: module loaded
[    2.801585] libphy: Fixed MDIO Bus: probed
[    2.802864] meson8b-dwmac c9410000.ethernet: IRQ eth_wake_irq not found
[    2.806646] meson8b-dwmac c9410000.ethernet: IRQ eth_lpi not found
[    2.812865] meson8b-dwmac c9410000.ethernet: PTP uses main clock
[    2.818713] meson8b-dwmac c9410000.ethernet: no reset control found
[    2.825503] meson8b-dwmac c9410000.ethernet: User ID: 0x11, Synopsys ID: 0x37
[    2.832009] meson8b-dwmac c9410000.ethernet: 	DWMAC1000
[    2.837167] meson8b-dwmac c9410000.ethernet: DMA HW capability register supported
[    2.844582] meson8b-dwmac c9410000.ethernet: RX Checksum Offload Engine supported
[    2.851998] meson8b-dwmac c9410000.ethernet: COE Type 2
[    2.857180] meson8b-dwmac c9410000.ethernet: TX Checksum insertion supported
[    2.864159] meson8b-dwmac c9410000.ethernet: Wake-Up On Lan supported
[    2.870579] meson8b-dwmac c9410000.ethernet: Normal descriptors
[    2.876409] meson8b-dwmac c9410000.ethernet: Ring mode enabled
[    2.882187] meson8b-dwmac c9410000.ethernet: Enable RX Mitigation via HW Watchdog Timer
[    2.890585] libphy: stmmac: probed
[    2.895072] VFIO - User Level meta-driver version: 0.3
[    2.900409] dwc3 c9000000.dwc3: Failed to get clk 'ref': -2
[    2.905259] ehci_hcd: USB 2.0 'Enhanced' Host Controller (EHCI) Driver
[    2.910583] ehci-pci: EHCI PCI platform driver
[    2.915036] ehci-platform: EHCI generic platform driver
[    2.920377] ohci_hcd: USB 1.1 'Open' Host Controller (OHCI) Driver
[    2.926275] ohci-pci: OHCI PCI platform driver
[    2.930719] ohci-platform: OHCI generic platform driver
[    2.936625] usbcore: registered new interface driver usb-storage
[    2.942025] mousedev: PS/2 mouse device common for all mice
[    2.948374] i2c /dev entries driver
[    2.954469] sdhci: Secure Digital Host Controller Interface driver
[    2.956868] sdhci: Copyright(c) Pierre Ossman
[    2.961228] Synopsys Designware Multimedia Card Interface Driver
[    2.968861] meson-gx-mmc d0072000.mmc: Got CD GPIO
[    2.998496] meson-gx-mmc d0074000.mmc: allocated mmc-pwrseq
[    3.026127] sdhci-pltfm: SDHCI platform and OF driver helper
[    3.027132] ledtrig-cpu: registered to indicate activity on CPUs
[    3.032830] meson-sm: secure-monitor enabled
[    3.036792] mmc0: new high speed SDHC card at address 0001
[    3.036940] gxl-crypto c883e000.crypto: will run requests pump with realtime priority
[    3.042575] mmcblk0: mmc0:0001 EB1QT 29.8 GiB 
[    3.049728] gxl-crypto c883e000.crypto: will run requests pump with realtime priority
[    3.055848]  mmcblk0: p1 p2
[    3.062541] hid: raw HID events driver (C) Jiri Kosina
[    3.069750] usbcore: registered new interface driver usbhid
[    3.075075] usbhid: USB HID core driver
[    3.079243] platform-mhu c883c404.mailbox: Platform MHU Mailbox registered
[BL31]: tee size: 0
[    3.092824] NET: Registered protocol family 17
[    3.093115] Key type dns_resolver registered
[    3.096615] registered taskstats version 1
[    3.100182] Loading compiled-in X.509 certificates
[    3.105046] zswap: loaded using pool lzo/zbud
[    3.109683] Key type ._fscrypt registered
[    3.113292] Key type .fscrypt registered
[    3.117153] Key type fscrypt-provisioning registered
[    3.122959] Btrfs loaded, crc32c=crc32c-generic
[    3.127542] Key type encrypted registered
[    3.136064] mmc1: new HS200 MMC card at address 0001
[    3.136871] mmcblk1: mmc1:0001 016G72 14.7 GiB 
[    3.140301] mmcblk1boot0: mmc1:0001 016G72 partition 1 4.00 MiB
[    3.146167] mmcblk1boot1: mmc1:0001 016G72 partition 2 4.00 MiB
[    3.149068] meson-drm d0100000.vpu: Queued 3 outputs on vpu
[    3.151833] mmcblk1rpmb: mmc1:0001 016G72 partition 3 4.00 MiB, chardev (241:0)
[    3.157425] [drm] Supports vblank timestamp caching Rev 2 (21.10.2013).
[    3.170999] [drm] No driver support for vblank timestamp query.
[    3.205173] meson-dw-hdmi c883a000.hdmi-tx: Detected HDMI TX controller v2.01a with HDCP (meson_dw_hdmi_phy)
[    3.209861] meson-dw-hdmi c883a000.hdmi-tx: registered DesignWare HDMI I2C bus driver
[    3.217911] meson-drm d0100000.vpu: bound c883a000.hdmi-tx (ops meson_dw_hdmi_ops)
[    3.225176] [drm] Initialized meson 1.0.0 20161109 for d0100000.vpu on minor 0
[    3.241719] Console: switching to colour frame buffer device 90x36
[    3.267403] meson-drm d0100000.vpu: fb0: mesondrmfb frame buffer device
[    3.274969] libphy: mdio_mux: probed
[    3.278494] libphy: mdio_mux: probed
[    3.325919] phy phy-d0078080.phy.3: unsupported PHY mode 5
[    3.329184] xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
[    3.331350] xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 1
[    3.339057] xhci-hcd xhci-hcd.0.auto: hcc params 0x0228f664 hci version 0x100 quirks 0x0000000002010010
[    3.348298] xhci-hcd xhci-hcd.0.auto: irq 34, io mem 0xc9000000
[    3.354413] usb usb1: New USB device found, idVendor=1d6b, idProduct=0002, bcdDevice= 5.06
[    3.362314] usb usb1: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.369457] usb usb1: Product: xHCI Host Controller
[    3.374285] usb usb1: Manufacturer: Linux 5.6.2-arm-64 xhci-hcd
[    3.380151] usb usb1: SerialNumber: xhci-hcd.0.auto
[    3.385501] hub 1-0:1.0: USB hub found
[    3.388795] hub 1-0:1.0: 3 ports detected
[    3.393033] xhci-hcd xhci-hcd.0.auto: xHCI Host Controller
[    3.398110] xhci-hcd xhci-hcd.0.auto: new USB bus registered, assigned bus number 2
[    3.405705] xhci-hcd xhci-hcd.0.auto: Host supports USB 3.0 SuperSpeed
[    3.412203] usb usb2: We don't know the algorithms for LPM for this host, disabling LPM.
[    3.421425] usb usb2: New USB device found, idVendor=1d6b, idProduct=0003, bcdDevice= 5.06
[    3.430835] usb usb2: New USB device strings: Mfr=3, Product=2, SerialNumber=1
[    3.437990] usb usb2: Product: xHCI Host Controller
[    3.442815] usb usb2: Manufacturer: Linux 5.6.2-arm-64 xhci-hcd
[    3.448675] usb usb2: SerialNumber: xhci-hcd.0.auto
[    3.454004] hub 2-0:1.0: USB hub found
[    3.457361] hub 2-0:1.0: config failed, hub doesn't have any ports! (err -19)
[    3.466284] meson-gx-mmc d0070000.mmc: allocated mmc-pwrseq
[    3.497309] scpi_protocol scpi: SCP Protocol legacy pre-1.0 firmware
domain-0 init dvfs: 4
domain-1 init dvfs: 4
[    3.521563] printk: console [netcon0] enabled
[    3.524591] netconsole: network logging started
[    3.528645] hctosys: unable to open rtc device (rtc0)
[    3.533348] ALSA device list:
[    3.537288]   No soundcards found.
[    3.541271] RAMDISK: gzip image found at block 0
[    3.547297] mmc2: queuing unknown CIS tuple 0x01 (3 bytes)
[    3.560668] mmc2: queuing unknown CIS tuple 0x1a (5 bytes)
[    3.568245] mmc2: queuing unknown CIS tuple 0x1b (8 bytes)
[    3.571957] mmc2: queuing unknown CIS tuple 0x14 (0 bytes)
[    3.578795] mmc2: queuing unknown CIS tuple 0x80 (1 bytes)
[    3.581728] mmc2: queuing unknown CIS tuple 0x81 (1 bytes)
[    3.587244] mmc2: queuing unknown CIS tuple 0x82 (1 bytes)
[    3.592715] mmc2: new high speed SDIO card at address 0001
[    3.615203] RAMDISK: incomplete write (16269 != 27512)
[    3.617650] write error
[    3.620180] VFS: Cannot open root device "live:LABEL=ROOTFS" or unknown-block(0,0): error -6
[    3.629307] Please append a correct "root=" boot option; here are the available partitions:
[    3.649900] 0100            4096 ram0 
[    3.649903]  (driver?)
[    3.656760] 0101            4096 ram1 
[    3.656761]  (driver?)
[    3.662940] 0102            4096 ram2 
[    3.662941]  (driver?)
[    3.668692] 0103            4096 ram3 
[    3.668694]  (driver?)
[    3.674294] 0104            4096 ram4 
[    3.674296]  (driver?)
[    3.680233] 0105            4096 ram5 
[    3.680234]  (driver?)
[    3.686199] 0106            4096 ram6 
[    3.686201]  (driver?)
[    3.692130] 0107            4096 ram7 
[    3.692131]  (driver?)
[    3.698174] 0108            4096 ram8 
[    3.698175]  (driver?)
[    3.704215] 0109            4096 ram9 
[    3.704217]  (driver?)
[    3.710254] 010a            4096 ram10 
[    3.710256]  (driver?)
[    3.716365] 010b            4096 ram11 
[    3.716367]  (driver?)
[    3.722497] 010c            4096 ram12 
[    3.722498]  (driver?)
[    3.728624] 010d            4096 ram13 
[    3.728626]  (driver?)
[    3.734749] 010e            4096 ram14 
[    3.734751]  (driver?)
[    3.740871] 010f            4096 ram15 
[    3.740872]  (driver?)
[    3.747015] b300        31260672 mmcblk0 
[    3.747018]  driver: mmcblk
[    3.753734]   b301          524288 mmcblk0p1 ac846010-01
[    3.753736] 
[    3.760623]   b302        30407392 mmcblk0p2 ac846010-02
[    3.760625] 
[    3.767433] b320        15388672 mmcblk1 
[    3.767435]  driver: mmcblk
[    3.773906] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
[    3.782089] CPU: 4 PID: 1 Comm: swapper/0 Not tainted 5.6.2-arm-64 #20.05.1
[    3.788982] Hardware name: Amlogic Meson GXM (S912) Q200 Development Board (DT)
[    3.796230] Call trace:
[    3.798661]  dump_backtrace+0x0/0x1d0
[    3.801764] random: fast init done
[    3.802273]  show_stack+0x14/0x20
[    3.802316]  dump_stack+0xbc/0x100
[    3.829193]  panic+0x160/0x320
[    3.832097]  mount_block_root+0x1b0/0x24c
[    3.836061]  mount_root+0x124/0x154
[    3.839509]  prepare_namespace+0x158/0x198
[    3.843563]  kernel_init_freeable+0x22c/0x24c
[    3.847879]  kernel_init+0x10/0xfc
[    3.851240]  ret_from_fork+0x10/0x18
[    3.854788] SMP: stopping secondary CPUs
[    3.858689] Kernel Offset: disabled
[    3.862108] CPU features: 0x00002,20002004
[    3.866158] Memory Limit: none
[    3.869191] ---[ end Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0) ]---
```

Is this the culprit? `rootfs image is not initramfs (incorrect cpio method used: use -H newc option); looks like an initrd`

Indeed. With

```
mkdir initrd && cd initrd
xz -dc < /mnt/boot/aarch64/loader/initrd | cpio -idmv
find . | cpio -H newc -o > ../initrdfile
cd ..
sudo mkimage -A arm64 -O linux -T ramdisk -C none -a 0 -e 0 -n uInitrd -d initrdfile '/media/me/BOOT/uInitrd'
```

we __succeed loading initrd and start running systemd from it__:

```
[    4.352957] Run /init as init process
[    4.366118] mmc2: queuing unknown CIS tuple 0x1a (5 bytes)
[    4.373577] mmc2: queuing unknown CIS tuple 0x1b (8 bytes)
[    4.377260] mmc2: queuing unknown CIS tuple 0x14 (0 bytes)
[    4.383935] mmc2: queuing unknown CIS tuple 0x80 (1 bytes)
[    4.387283] mmc2: queuing unknown CIS tuple 0x81 (1 bytes)
[    4.392484] systemd[1]: System time before build time, advancing clock.
[    4.399079] mmc2: queuing unknown CIS tuple 0x82 (1 bytes)
[    4.399115] mmc2: new high speed SDIO card at address 0001
[    4.445994] systemd[1]: systemd +suse.138.gf8adabc2b1 running in system mode. (+PAM -AUDIT +SELINUX -IMA +APPARMOR -SMACK +SYSVINIT +UTMP +LIBCRYPTSETUP +GCRYPT +GNUTLS +ACL +XZ +LZ4 +SECCOMP +BLKID +ELFUTILS +KMOD -IDN2 -IDN +PCRE2 default-hierarchy=hybrid)
[    4.474646] systemd[1]: Detected architecture arm64.
[    4.478432] systemd[1]: Running in initial RAM disk.
[    4.481629] random: fast init done
[    4.540747] systemd[1]: No hostname configured.
[    4.544281] systemd[1]: Set hostname to <localhost>.
[    4.548314] random: systemd: uninitialized urandom read (16 bytes read)
[    4.554598] systemd[1]: Initializing machine ID from random generator.
[    4.618059] random: ln: uninitialized urandom read (6 bytes read)
[    4.850790] random: systemd: uninitialized urandom read (16 bytes read)
[    5.617859] dracut: FATAL: iscsiroot requested but kernel/initrd does not support iscsi
[    5.622298] dracut: Refusing to continue
[    5.769096] systemd-shutdown[1]: Syncing filesystems and block devices.
[    5.772263] systemd-shutdown[1]: Sending SIGTERM to remaining processes...
[    5.796241] systemd-shutdown[1]: Sending SIGKILL to remaining processes...
[    5.811760] systemd-shutdown[1]: Unmounting file systems.
[    5.817982] [473]: Remounting '/' read-only in with options '(null)'.
[    5.821652] systemd-shutdown[1]: All filesystems unmounted.
[    5.826766] systemd-shutdown[1]: Deactivating swaps.
[    5.831433] systemd-shutdown[1]: All swaps deactivated.
[    5.836371] systemd-shutdown[1]: Detaching loop devices.
[    5.844839] systemd-shutdown[1]: All loop devices detached.
[    5.847165] systemd-shutdown[1]: Detaching DM devices.
[    5.852586] systemd-shutdown[1]: All DM devices detached.
[    5.857680] systemd-shutdown[1]: All filesystems, swaps, loop devices and DM devices detached.
[    5.868506] systemd-shutdown[1]: Syncing filesystems and block devices.
[    5.872795] systemd-shutdown[1]: Halting system.
[    5.962587] xhci-hcd xhci-hcd.0.auto: remove, state 4
[    5.992985] usb usb2: USB disconnect, device number 1
[    6.014191] random: crng init done
[    6.026694] random: 7 urandom warning(s) missed due to ratelimiting
[    6.027722] xhci-hcd xhci-hcd.0.auto: USB bus 2 deregistered
[    6.064166] xhci-hcd xhci-hcd.0.auto: remove, state 4
[    6.095293] usb usb1: USB disconnect, device number 1
[    6.133006] xhci-hcd xhci-hcd.0.auto: USB bus 1 deregistered
[    6.166069] reboot: System halted
```
