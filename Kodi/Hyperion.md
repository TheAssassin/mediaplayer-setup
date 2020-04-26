# Hyperion

Ambient lighting using Neopixels and an ESP8266 or other Arduino. This can work via a USB port or even via WLAN.

Unfortunately this seems not to be documented end-to-end anywhere.

## Hardware setup

Use WeMOS D1 Mini with WLED 0.9.1 (build 2002222) firmware from https://github.com/Aircoookie/WLED/

## Firmware setup

The Aircoookie firmware can be configured over WLAN, see https://github.com/Aircoookie/WLED/wiki. Configure number of LEDs, etc.

## Hyperion installation

The add-on `service.hyperion.service` needs to be installed.

## Hyperion configuration

Configuration needs to be created (e.g., with HyperCon V1.03.3, a Java-based tool that runs on a desktop computer).


Device needs to be set to e.g., `/dev/ttyUSB0`, and baudrate needs to be set to 115,200 (otherwise `systemctl status service.hyperion.service` will say `Unable to open RS232 device (IO Exception (25): Inappropriate ioctl for device`).

Then it needs to be __hand-edited for Amlogic-based devices__ like this: Since HyperCon does not support the Amlogic grabber, select "Internal Frame Grabber" in HyperCon, create the configuration, and then manually replace the Internal Frame Grabber section in the JSON with

```
	// AMLOGIC GRABBER CONFIG
        "amlgrabber" :
        {
                "priority" : 800,
                "width" : 70,
                "height" : 40,
                "frequency_Hz" : 20.0
        },
```

It then needs to be placed into `~/.kodi/userdata/addon_data/service.hyperion/hyperion.config.json`.

After a restart one should be able to access port 8099 with a web browser. Debug with `systemctl status service.hyperion.service` and `systemctl restart service.hyperion.service journalctl -u service.hyperion.service -n 40` (why so complicated, why doesn't `systemctl status` do this by default...). `KODICHECK ERROR: Kodi Connection error (0)` may indicate a defective `~/.kodi/userdata/addon_data/service.hyperion/hyperion.config.json`.
