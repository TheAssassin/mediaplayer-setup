# Custom fonts and colors for Kodi default skin

In Kodi, fonts are defined by and shipped with the skin. The default skin is on a read-only squashfs partition on *ELEC systems.

However, sometimes it is desirable to have custom fonts for the default skin. To achieve this, we need to actually copy the default skin, and change the fonts in the copy, then (manually?) activate the new skin, and finally select it.

Similarly, colors can be changed.

Like this:

```
cp -r /usr/share/kodi/addons/skin.estuary ~/.kodi/addons/skin.custom

cd ~/.kodi/addons/skin.custom

find . -type f -exec sed -i -e 's|estuary|custom|g' {} \;
find . -type f -exec sed -i -e 's|Estuary|Custom|g' {} \;

# NOTICE: This is just an example; you are responsible for ensuring any relevant license compliance
wget -c "https://github.com/Coheed/OC-Bo.de/blob/master/files/fonts/RotisSansSerifStd/RotisSansSerifStd.ttf?raw=true" -O fonts/RotisSansSerifStd.ttf
wget -c "https://github.com/ameyakarve/BrassPlate/blob/master/webapp/app/styles/fonts/Rotis%20Sans%20Serif%20Extra%20Bold%2075.ttf?raw=true" -O fonts/RotisSansSerifStd-ExtraBold.ttf

sed -i -e 's|Roboto-Thin.ttf|RotisSansSerifStd.ttf|g' ./xml/Font.xml
sed -i -e 's|NotoSans-Regular.ttf|RotisSansSerifStd.ttf|g' ./xml/Font.xml
sed -i -e 's|NotoSans-Bold.ttf|RotisSansSerifStd-ExtraBold.ttf|g' ./xml/Font.xml
sed -i -e 's|arial.ttf|RotisSansSerifStd.ttf|g' ./xml/Font.xml

# Could customize font sizes as well, but this may require further changes
# in the skin
# sed -i -e 's|<size>[0-9]*</size>|<size>36</size>|g' ./xml/Font.xml
 
rm ./fonts/Noto*
rm ./fonts/*_licence.txt
rm ./fonts/Roboto-Thin.ttf
rm ./fonts/*_license.txt

cd ~

cp ./.kodi/userdata/guisettings.xml ./.kodi/userdata/guisettings.xml.old
sed -i -e 's|estuary|custom|g' ./.kodi/userdata/guisettings.xml

sed -i -e 's|arial.ttf|RotisSansSerifStd.ttf|g' ./.kodi/userdata/guisettings.xml

# While we are at it, also fix the non-fitting green color
sed -i -e 's|11E7B1|000000|g' ./colors/charcoal.xml

killall kodi.bin
```

FIXME: Still need to manually activate the Custom skin and select the `charcoal` color.

## Custom fonts for subtitles

Seems like subtitles can only use the fonts installed in the system at `/usr/share/kodi/media/Fonts/`.

So we either have to remaster the squashfs SYSTEM partition, or do some trickery:

```
mount --bind ~/.kodi/addons/skin.custom/fonts/ /usr/share/kodi/media/Fonts/

cat >> ~/.config/autostart.sh <<\EOF
mount --bind ~/.kodi/addons/skin.custom/fonts/ /usr/share/kodi/media/Fonts/
EOF
chmod +x ~/.config/autostart.sh

sed -i -e 's|<setting id="subtitles.font">.*</setting>|<setting id="subtitles.font">RotisSansSerifStd-ExtraBold.ttf</setting>|g' /storage/.kodi/userdata/guisettings.xml
killall kodi.bin
```

Now our custom fonts can be selected. Note that no subtitles are shown at all until one of the new fonts is selected in Settings -> Player -> Language.
