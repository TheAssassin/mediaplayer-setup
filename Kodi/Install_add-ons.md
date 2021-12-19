# Installing add-ons

## Installing add-ons into the running system

How can we install and pre-activate add-ons _including their dependencies_ in the running system?

For example, to ship just one add-on that would pre-configure the entire system, and install additional add-ons.

Presumably something along the lines of

```
xbmc.executebuiltin('InstallAddon(id)')
xbmc.executebuiltin('UpdateLocalAddons')
xbmc.executebuiltin('EnableAddon(id)')
```
References
* https://kodi.wiki/view/List_of_built-in_functions
* https://www.kodinerds.net/index.php/Thread/54032-InstallAddon-id-funktioniert-nicht/
* https://github.com/xbmc/xbmc/blob/master/xbmc/addons/AddonInstaller.cpp

To be investigated. Insights welcome.

## Preinstalling add-ons in SYSTEM

How can we preinstall and pre-activate add-ons _including their dependencies_ in the squashfs `SYSTEM` file?

To be investigated. Insights welcome.

## Candidates for preinstalling

### Global

* YouTube

### German

* Tagesschau
* MediathekViewWeb (not MediathekView)

### API Keys for YouTube app

`/storage/.kodi/userdata/addon_data/plugin.video.youtube/api_keys.json` - entering those through the Kodi GUI is _very_ tedious.
