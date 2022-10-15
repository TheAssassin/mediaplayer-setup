# HDMI-CEC

HDMI-CEC, also marketed by vendors like Samsung under names like, e.g., "Anynet+", allows you to control Kodi from your TV remote control.

Unfortunately, with some versions of LibreELEC, this requires you to select "Kodi" from the TV menu "Anynet+" each time after a cold boot.

![image](https://user-images.githubusercontent.com/2480569/192144726-7bd02303-9230-4806-9c52-63d78c70d6a9.png)

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
```

This has been tested successfully on `LibreELEC (community): nightly-20220918-bb49fdc (AMLGX.arm)` with kernel `Linux LibreELEC 5.19.0 #1 SMP PREEMPT Sun Sep 18 15:13:27 UTC 2022 aarch64 GNU/Linux` running on a X96.

Alternatively, the same effect also be achieved with systemd:

```
cat > /storage/.config/system.d/cecfix.service <<\EOF
[Unit]
Description=Make CEC work on LibreELEC
After=kodi.service
Requires=kodi.service

[Install]
WantedBy=kodi.service

[Service]
Type=oneshot
RemainAfterExit=true
ExecStartPre=/usr/bin/sleep 15
ExecStart=/usr/bin/cec-ctl --to 0 --active-source phys-addr=1.0.0.0
EOF

systemctl enable cecfix
systemctl start cecfix
# Created symlink /storage/.config/system.d/kodi.service.wants/cecfix.service → /storage/.config/system.d/cecfix.service.
```

For __CoreELEC__, the following _may_ help (to be verified): https://discourse.coreelec.org/t/coreelec-19-5-matrix-rc2-discussion/18858/78?u=probono
