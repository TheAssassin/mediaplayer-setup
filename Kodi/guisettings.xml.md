# guisettings.xml

## Set everything to German

"German" is just a placeholder for your locale, serving as an example here.

Why is this spread out over n settings? It would be neat to select "German" and have _everything_ German with just one setting. Maybe even based on geo-ip location.

```
sed -i -e 's|<setting id="locale.activekeyboardlayout">.*</setting>|<setting id="locale.activekeyboardlayout">German QWERTZ</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.keyboardlayouts">.*</setting>|<setting id="locale.keyboardlayouts">German QWERTZ</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.timezonecountry">.*</setting>|<setting id="locale.timezonecountry">Germany</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.country">.*</setting>|<setting id="locale.country">Deutschland</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.language">.*</setting>|<setting id="locale.language">resource.language.de_de</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.timezone">.*</setting>|<setting id="locale.timezone">Europe/Berlin</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.use24hourclock" default=".*">regional</setting>|<setting id="locale.use24hourclock" default="true">regional</setting>|g' ~/.kodi/userdata/guisettings.xml
```

__Note:__ It may be necessary to also install an add-on to support German; to be investigated.
