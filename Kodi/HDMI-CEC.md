# HDMI-CEC

HDMI-CEC, also marketed by vendors like Samsung under names like, e.g., "Anynet+", allows you to control Kodi from your TV remote control.

Unfortunately, with some versions of LibreELEC, this requires you to select "Kodi" from the TV menu "Anynet+" each time after a cold boot.

Workaround: Execute the command `cec-ctl --to 0 --active-source phys-addr=1.0.0.0` __after__ Kodi has already been started.

```
cat >> ~/.config/autostart.sh <<\EOF

# In a few seconds, when Kodi is hopefully already running,
# make the Samsung TV control Kodi via HDMI-CEC
( sleep 15 &&  cec-ctl --to 0 --active-source phys-addr=1.0.0.0 ) &
# FIXME: Find a way to execute a script when Kodi is running
# instead of before Kodi is started
EOF
chmod +x ~/.config/autostart.sh
