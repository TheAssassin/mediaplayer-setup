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

TODO: Document how to find devices on the network using Zeroconf from within an add-on.

https://github.com/xbmc/xbmc/blob/9216e28bc4300eca57dc9671035fc49beb1fa007/tools/EventClients/lib/python/zeroconf.py#L40


References
* https://github.com/xbmc/xbmc/blob/master/tools/EventClients/lib/python/zeroconf.py
