# Hyperion

Ambient lighting using Neopixels and an ESP8266 or other Arduino.

Configuration needs to be vreated with HyperCon V1.03.3 (22.10.2017) and then needs to be __hand-edited for Amlogic-based devices__ like this:

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
