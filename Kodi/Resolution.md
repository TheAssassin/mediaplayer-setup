# Adding custom resolutions

Normally the file `/storage/.kodi/userdata/disp_cap` does not exist but if you create it, you can add custom resolutions there. Otherwise the resolutions that are detected using EDID are being used.

```
AlexELEC:~ # mount /storage/ -o remount,rw
AlexELEC:~ # cat /sys/class/amhdmitx/amhdmitx0/disp_cap > /storage/.kodi/userdata/disp_cap
AlexELEC:~ # nano /storage/.kodi/userdata/disp_cap
# Add, e.g.,
# 1366x768p50Hz
# 1366x768p60Hz
AlexELEC:~ # killall kodi.bin
AlexELEC:~ # reboot
```

## CoreELEC

__CoreELEC__ may have trouble detecting the correct resolution if the media player device is powered from the TV device. In this case, the following forces a certain resolution at boot time: https://discourse.coreelec.org/t/coreelec-19-5-matrix-rc2-discussion/18858/78?u=probono

```
cat /sys/class/amhdmitx/amhdmitx0/disp_cap > /storage/.kodi/userdata/disp_cap
```
