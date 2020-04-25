# aml_autoscript

Amlogic-based systems have a mechanism involving a file called `aml_autoscript` that allows one to execute U-Boot commands from external media such as SD card or USB mass storage.

Unfortunately, the exact workings of `aml_autoscript` seem to be undocumented.

So here is what we have figured out. Feel free to correct.

* When an Amlogic system detects that the reset button ("toothpick method") has been pressed during power-up, it (probably the stock U-Boot on the device) searches for a file called `aml_autoscript` on external media such as SD card or USB mass storage (this is known to work at least for the first partition if it is formatted fat32 - to be documented whether it also works for other partitions and filesystems)
* For models based on Amlogic S802/S805/812 this might NOT work from USB but only from SD card (to be verified). This might be due to an older U-Boot version installed from the factory on those machines. (To be determined whether this limitation can be lifted by using a newer U-Boot.)
* The file `aml_autoscript` can be created by editing a text file `aml_autoscript.txt`, and then running `mkimage -A arm -O linux -T script -C none -d aml_autoscript.txt aml_autoscript`
* `aml_autoscript.txt` can contain U-Boot commands
* It should be possible to chainload a newer U-Boot from `aml_autoscript`. To be determined: Will newer (mainline) U-Boot also search for and execute `aml_autoscript`? If so, how can we avoid an infinite loop?

Note: On some 3rd-party systems you might also see `s905_autoscript`. This seems to be something introduced by @150balbes, not something official from Amlogic. Hence it is not covered here.
