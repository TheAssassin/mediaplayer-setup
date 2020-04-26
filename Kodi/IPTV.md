# IPTV configuration

## Example for Germany

The https://github.com/kodi-pvr/pvr.iptvsimple/releases add-on (an official Kodi add-on from their repository) can be used to play IPTV. To become usable, one needs to configure it with playlists and optionally EPG data. https://www.kodi-tipps.de/kodi-iptv-einrichten-live-tv-mit-kodi-anschauen/ has more detailed information (in German).

This example is for Germany; it should be similar for other countries.

## Pre-configure out-of-the-box

To be written.

Install (how exactly?) the `pvr.iptvsimple` add-on into the SYSTEM squashfs. Also put there (where exactly?) a pre-configuration similar to the one below.

## Configure on the running system

Working.

Install the `pvr.iptvsimple` add-on.
Then, do:

```
cat > /storage/.kodi/userdata/addon_data/pvr.iptvsimple/settings.xml <<\EOF
<settings version="2">
    <setting id="epgCache">true</setting>
    <setting id="epgPath" default="true"></setting>
    <setting id="epgPathType">1</setting>
    <setting id="epgTimeShift" default="true">0</setting>
    <setting id="epgTSOverride" default="true">false</setting>
    <setting id="epgUrl" default="true">https://rytec.ricx.nl/epg_data/rytecDE_Basic.gz</setting>
    <setting id="logoBaseUrl" default="true"></setting>
    <setting id="logoFromEpg">1</setting>
    <setting id="logoPath" default="true"></setting>
    <setting id="logoPathType">1</setting>
    <setting id="m3uCache" default="true">true</setting>
    <setting id="m3uPath" default="true"></setting>
    <setting id="m3uPathType">1</setting>
    <setting id="m3uUrl">http://bit.ly/kn-kodi</setting>
    <setting id="startNum">1</setting>
</settings>
EOF
killall kodi.bin
```

## Open questions

Contributions welcome.

### Adding TV stations for multiple countries

How can configuration for multiple countries be added, e.g., Germany (as shown above) and USA?

For USA, there is e.g., https://freeiptvserver.com/dl/us_260420_iptvsource_com.m3u

Strangely, even free-to-air (FTA) local/regional US channels sometimes don't provide globally-watchable streams directly hosted by the broadcasting station itself (unlike in Germany, where the broadcasting station itself offers IPTV streams). Why? After all, FTA stations are supposed to be either publicly funded or advertising based. So why don't they offer their signals directly to end users? It may be necessary to find services which "re-broadcast" their signals. But beware: Some of those services may either be location-restricted themselves, locked to certain device MAC addresses, or cost money or are otherwise shady (sometimes under the disguise of "donations", e.g., services made for the [IPTV Stalker Middleware](https://github.com/azhurb/stalker_portal) which can be accessed by https://github.com/kodi-pvr/pvr.stalker. (Remember that all we want is to watch FTA stations, not anything that costs money.)

For Global, there is e.g., https://bit.ly/FluxusTV-IPTV = https://pastebin.com/raw/ZzGTySZE

But those apparently don't have matching EPG data.

Possibly we can nest m3u like this:

```
#EXTINF:-1 group-title="SERVER 8" logo="icon.png", Playlist title
playlist1.m3u8
playlist2.m3u8
```

Source: https://stackoverflow.com/a/45638693

To be tested. Any insights welcome.
