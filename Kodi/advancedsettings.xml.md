# advancedsettings.xml

The `advancedsettings.xml` file can be used to pre-configure the system. Its settings are not accessible from the GUI.

__Note:__ The `advancedsettings.xml` file does not exist by default. You have to create it first! 

## Disabling the Kodi splash

Typically, there are up to 3 (three) different splash screens, which clutters up the visual appearance of the boot process:

- Device boot splash (e.g., loaded by U-Boot) (usually advertises the hardware box name or its manufacturer)
- OS boot splash (e.g., loaded by `fbi` launched by `systemd`) (usually advertises the operating system, e.g., *ELEC) (can be changed by using `/flash/oemsplash.png`)
- Kodi splash

```
cat > ~/.kodi/userdata/advancedsettings.xml <<\EOF
<advancedsettings version="1.0">
    <splash>false</splash>
</advancedsettings>
EOF

killall kodi.bin
```

## Overriding guisettings.xml settings

https://kodi.wiki/view/Advancedsettings.xml:

> You can also define the settings normally defined in the GUI (and stored in `guisettings.xml`) in `advancedsettings.xml`. Most guisettings.xml settings defined in `advancedsettings.xml` will override the `guisettings.xml` values, __and the settings will be removed completely from the interface__. 
