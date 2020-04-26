# guisettings.xml

## Set everything to German

```
sed -i -e 's|<setting id="locale.activekeyboardlayout">.*</setting>|<setting id="locale.activekeyboardlayout">German QWERTZ</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.keyboardlayouts">.*</setting>|<setting id="locale.keyboardlayouts">German QWERTZ</setting>|g' ~/.kodi/userdata/guisettings.xml
sed -i -e 's|<setting id="locale.timezonecountry">.*</setting>|<setting id="locale.timezonecountry">Germany</setting>|g' ~/.kodi/userdata/guisettings.xml
```
