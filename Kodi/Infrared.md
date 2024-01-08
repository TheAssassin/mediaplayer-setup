# Infrared remote control

If you cannot use HDMI-CEC, then you can use the infrared remote control that was shipped with the device.

Create `/storage/.config/rc_maps.cfg` and make it contain `* * x96max.toml` (this tells the system to use `/usr/lib/udev/rc_keymaps/x96max.toml`).

Then run `ir-keytable -a /storage/.config/rc_maps.cfg`. From now on, the infrared remote control should be working.

To train other infrared remote controls, see https://discourse.coreelec.org/t/how-to-configure-ir-remote-control/31 and https://wiki.libreelec.tv/configuration/ir-remotes.
