# aml_autoscript

Amlogic-based systems have a mechanism involving a file called `aml_autoscript` that allows one to execute U-Boot commands from external media such as SD card or USB mass storage.

Unfortunately, the exact workings of `aml_autoscript` seem to be undocumented.

So here is what we have figured out. Feel free to correct.

# aml_autoscript theory of operation

* When an Amlogic system detects that the reset button ("toothpick method") has been pressed during power-up, it (probably the stock U-Boot on the device) searches for a file called `aml_autoscript` on external media such as SD card or USB mass storage (this is known to work at least for the first partition if it is formatted fat32 - to be documented whether it also works for other partitions and filesystems)
* For models based on Amlogic S802/S805/812 this might NOT work from USB but only from SD card (to be verified). This might be due to an older U-Boot version installed from the factory on those machines. (To be determined whether this limitation can be lifted by using a newer U-Boot.)
* The file `aml_autoscript` can be created by editing a text file `aml_autoscript.txt`, and then running `mkimage -A arm -O linux -T script -C none -d aml_autoscript.txt aml_autoscript`
* `aml_autoscript.txt` can contain U-Boot commands
* It should be possible to chainload a newer U-Boot from `aml_autoscript`. To be determined: Will newer (mainline) U-Boot also search for and execute `aml_autoscript`? If so, how can we avoid an infinite loop?
* Usually `aml_autoscript` scripts set some variables, store them, and then reboot the system (`setenv key value`, `saveenv`, `reset`). This is so that one does not have to power-up with the reset button being pressed all the time in order to boot what the `aml_autoscript` is supposed to boot. But `aml_autoscript` scripts can also be used to directly boot something, without the need for `saveenv`. This is especially interesting if a certain action should ONLY be executed/booted if the reset button is being pressed during power-up, and subsequent boots should boot as usual

In some instructions you will read that you need to boot into the stock Android, go to the "Backup & Restore" app, and select a zip file to "activate multi-boot". Probably the same effect can be achieved by using `aml_autoscript` and powering up with the reset button pressed ("toothpick method"). This needs to be verified.

Note: On some 3rd-party systems you might also see `s905_autoscript`. This seems to be something introduced by @150balbes, not something official from Amlogic. Hence it is not covered here.

## printenv, getenv, setenv, saveenv

U-Boot can store U-Boot environment variables persistently. To show them, run `printenv`. To set an U-Boot environment variable temporarily, run `setenv <key> <value>`. To persist all set U-Boot environment variables across boots, run `saveenv`.

There are some special U-Boot environment variables that determine how Amlogic systems are booted.

https://github.com/codesnake/uboot-amlogic/blob/master/common/cmd_reboot.c defines

* reboot_mode (`normal`, `factory_reset`, `update`, `usb_burning`, `charging`) - __to be documented__

According to https://github.com/longsleep/u-boot-odroidc/blob/master/arch/arm/include/asm/arch-m6tvd/reboot.h,

```
/*
 * Commands accepted by the arm_machine_restart() system call.
 *
 * AMLOGIC_NORMAL_BOOT     			Restart system normally.
 * AMLOGIC_FACTORY_RESET_REBOOT      Restart system into recovery factory reset.
 * AMLOGIC_UPDATE_REBOOT			Restart system into recovery update.
 * AMLOGIC_CHARGING_REBOOT     		Restart system into charging.
 * AMLOGIC_CRASH_REBOOT   			Restart system with system crach.
 * AMLOGIC_FACTORY_TEST_REBOOT    	Restart system into factory test.
 * AMLOGIC_SYSTEM_SWITCH_REBOOT  	Restart system for switch other OS.
 * AMLOGIC_SAFE_REBOOT       			Restart system into safe mode.
 * AMLOGIC_LOCK_REBOOT  			Restart system into lock mode.
 * elvis.yu---elvis.yu@amlogic.com
 */
 ```

https://github.com/codesnake/uboot-amlogic/blob/master/drivers/video/aml_video.c defines

* fb_addr
* fb_width
* fb_height
* display_width
* display_height
* display_bpp
* display_color_format_index
* display_layer
* display_color_fg
* display_color_bg

https://github.com/codesnake/uboot-amlogic/blob/master/common/cmd_logo.c defines

* bootup_720_offset
* bootup_720_size
* bootup_1080_offset
* bootup_1080_size

There are probably many more. Need to be documented.

## Open questions

Feel free to contribute

* Can Android be booted from SD card and/or USB? How?
