# guisettings.xml

__Note:__ If you want to preconfigure certain things and not have them available to be changed in the GUI, then you may want to use `advancedsettings.xml` instead.

## Setting everything to German

"German" is just a placeholder for your locale, serving as an example here.

### By remastering the Kodi system (is persistent upon Kodi factory reset)

Need to edit `/usr/share/kodi/config/guisettings.xml` in the squashfs `SYSTEM` file to include

```
    <setting id="locale.activekeyboardlayout">German QWERTZ</setting>
    <setting id="locale.audiolanguage" default="true">mediadefault</setting>
    <setting id="locale.charset" default="true">DEFAULT</setting>
    <setting id="locale.country">Deutschland</setting>
    <setting id="locale.keyboardlayouts">German QWERTZ</setting>
    <setting id="locale.language">resource.language.de_de</setting>
    <setting id="locale.longdateformat" default="true">regional</setting>
    <setting id="locale.shortdateformat" default="true">regional</setting>
    <setting id="locale.speedunit" default="true">regional</setting>
    <setting id="locale.subtitlelanguage">default</setting>
    <setting id="locale.temperatureunit" default="true">regional</setting>
    <setting id="locale.timeformat" default="true">regional</setting>
    <setting id="locale.timezone">Europe/Berlin</setting>
    <setting id="locale.timezonecountry">Germany</setting>
    <setting id="locale.use24hourclock" default="true">regional</setting>
    <setting id="subtitles.languages">German,English</setting>
```

__Note:__ It may be necessary to also install an add-on to support German; to be investigated.

### On an already-running system (is reverted upon Kodi factory reset)

Why is this spread out over n settings? It would be neat to select "German" and have _everything_ German with just one setting. Maybe even based on geo-ip location.

```
sed -i -e 's|<setting id="locale.activekeyboardlayout">.*</setting>|<setting id="locale.activekeyboardlayout">German QWERTZ</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.keyboardlayouts">.*</setting>|<setting id="locale.keyboardlayouts">German QWERTZ</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.timezonecountry">.*</setting>|<setting id="locale.timezonecountry">Germany</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.country">.*</setting>|<setting id="locale.country">Deutschland</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.language">.*</setting>|<setting id="locale.language">resource.language.de_de</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.timezone">.*</setting>|<setting id="locale.timezone">Europe/Berlin</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.use24hourclock" default=".*">regional</setting>|<setting id="locale.use24hourclock" default="true">regional</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="subtitles.languages">.*</setting>|<setting id="subtitles.languages">German,English</setting>|g' ~/.kodi/userdata/guisettings.xml
```

__Note:__ It may be necessary to also install an add-on to support German; to be investigated.
