# Infrared remote control

If you cannot use HDMI-CEC, then you can use the infrared remote control that was shipped with the device.

Create `/storage/.config/rc_maps.cfg` and make it contain `* * x96max.toml` (this tells the system to use `/usr/lib/udev/rc_keymaps/x96max.toml`).

Then run `ir-keytable -a /storage/.config/rc_maps.cfg`. From now on, the infrared remote control should be working.

To train other infrared remote controls, see https://discourse.coreelec.org/t/how-to-configure-ir-remote-control/31 and https://wiki.libreelec.tv/configuration/ir-remotes.

Assume we want to place the EPG on a certain button on the remote control (e.g,. the green "KD" button).

## Enabling the EPG key

This results in the EPG screen to be shown when a certain key is pressed on the remote control.

```
systemctl stop kodi
systemctl stop eventlircd
ir-keytable -p NEC,RC-5,RC-6,JVC,SONY -t
# Press the button
# 1814.767691: event type EV_MSC(0x04): scancode = 0x144
```

we find that the button uses scancode `0x144`, which is not mapped at all in `/usr/lib/udev/rc_keymaps/x96max.toml`.
So we copy it to `/storage/.config/rc_keymaps/` like this:
```
cp /usr/lib/udev/rc_keymaps/x96max.toml /storage/.config/rc_keymaps/x96mini.toml
```

edit it to contain

```
0x144 = "KEY_EPG"
```

and activate it by setting `nano /storage/.config/rc_maps.cfg` to `* * x96mini.toml`, then running `ir-keytable -a /storage/.config/rc_maps.cfg`.

## Putting random screens on IR buttons

__NOTE: The instructions in this section do not work yet. Any hints appreciated.__

Let's say that instead of the EPG window, we want to show the channel list.

https://kodi.wiki/view/Window_IDs says

```
tvchannels	WINDOW_TV_CHANNELS	10700	MyPVRChannels.xml
```


`/storage/.kodi/userdata/keymaps/keymap.xml` uses the window name which is the first column above, so we can use `ActivateWindow(tvchannels)`:

```
<keymap>
  <global>
    <remote>
      <epg>ActivateWindow(tvchannels)</epg>
    </remote>
  </global>
</keymap>
```

After a `killall kodi.bin`, pressing the EPG button on the remote control should result in the channel list being shown.

More documentation on keymaps can be found on http://kodi.wiki/view/keymaps.
