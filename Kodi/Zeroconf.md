# Zeroconf

Kodi allows Zeroconf to be used within add-ons.

## Announcing services to the network

Kodi allows add-ons to announce and deannounce services via `xbmc.Zeroconf`.

* `xbmc.Zeroconf()`
* `zeroconf.addTxtRecord`
* `zeroconf.publishService`
* `zeroconf.removeService`

See https://github.com/Memphiz/script.xbmc.airplay/search?q=zeroconf&unscoped_q=zeroconf for an example on how to use it.

## Browsing the network for services

There seems to be no really easy way for an add-on to be notified by Kodi about the services announced on the network by Zeroconf.

So here is a simple way to browse Zeroconf services in Python by using `avahi-browse`. Note that this does not use Kodi functionality. If you know a better/easier way, please let us know.

It needs a single file from http://amoffat.github.io/sh to make interacting with the `avahi-browse` command line tool really simple.

This has been tested on LibreELEC (Python 2.x).

```
#!/usr/bin/env python

import sh  # http://amoffat.github.io/sh - a single python file

avahi_browse = sh.Command("avahi-browse")

print("Browse all services with avahi-browse -artlp and return...")
print("==========================================================")
print("")

for line in avahi_browse("-arlpt", _iter=True):
    if line.startswith("="):
        print(line)

print("Keep browsing _wled._tcp services with avahi-browse -rlp and do not return...")
print("This can be used to detect devices that are switched on after this service")
print("has been started")
print("=============================================================================")
print("")

for line in avahi_browse("-rlp", '_wled._tcp', _iter=True):
    print(line)
```

If you know a better/easier way, please let us know.

## References

* https://github.com/xbmc/xbmc/blob/master/tools/EventClients/lib/python/zeroconf.py
