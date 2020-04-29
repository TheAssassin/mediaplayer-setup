# Boot logo

## Disabling the boot logo stored in firmware

The following takes the content of the U-Boot environment variable `prepare`, puts its content into the U-Boot environment variable `prepare-original`, and then clears the environment variable `prepare`.

As a result, the boot splash stored in firmware should no longer be shown.


```
fw_setenv prepare-original "$(fw_printenv | grep '^prepare=' | cut -d = -f 2-99)"

fw_printenv | grep '^prepare'

# Check that prepare= and prepare-original= have the same content
# Then do:

fw_setenv prepare ""
```

__Note:__ On a MXQ running AlexELEC, the original content of the U-Boot environment variable `prepare` was `logo size ; video open; video clear; video dev open ;imgread pic logo bootup ; bmp display ; bmp scale;
`. (This may be different for other machines and systems, hence make sure you back up the contents of your original one.)

Different machines/systems seem to do this slightly differently; e.g., on the x96 (non-mini) the `fw_...` commands are not working in Linux due to a missing device in `/dev`, and another U-Boot variable is being used. For this device, the following works, but needs to be done on the U-Boot console (could probably also be scripted):

```
setenv init_display-original "osd open;osd clear;imgread pic logo bootup $loadaddr;bmp display $bootup_offset;bmp scale"

getenv init_display-original

setenv init_display "osd open;osd clear"

saveenv
```

## Using a custom boot logo

See [aml_autoscript.md#loading-custom-boot-logo](aml_autoscript.md#loading-custom-boot-logo).
