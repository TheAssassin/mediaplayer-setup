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
* `script.logviewer`. This can be configured with `<setting id="error_popup">true</setting>` so that Python errors are shown on the screen as they happen, instead of just giving a meaningless error window:

`/storage/.kodi/userdata/addon_data/script.logviewer/settings.xml`

```
<settings version="2">
    <setting id="invert">false</setting>
    <setting id="lines" default="true">0</setting>
    <setting id="custom_window" default="true">false</setting>
    <setting id="error_popup">true</setting>
    <setting id="exceptions_only">true</setting>
    <setting id="http_server">false</setting>
    <setting id="port">8080</setting>
</settings>
```

### German

* Tagesschau
* MediathekViewWeb (not MediathekView)

## API Keys for YouTube app

`/storage/.kodi/userdata/addon_data/plugin.video.youtube/api_keys.json` - entering those through the Kodi GUI is _very_ tedious. To get a key: In https://console.developers.google.com/apis/library, under __YouTube Data API v3__, __Manage__ one needs to create a new  __OAuth 2.0 Client ID__ with Application Type __TV and Limited Input__.
