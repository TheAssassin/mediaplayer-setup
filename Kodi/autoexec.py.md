# autoexec.py

## Automatically launch Favorites

To automatically launch Favorites when Kodi is started:

```
cat >>  ~/.kodi/userdata/autoexec.py <<\EOF
import xbmc
xbmc.executebuiltin('ActivateWindow(Favourites)')
EOF

killall kodi.bin
```

Note that this opens a window instead of navigating to the Favorites tab on the main screen.

How can this be changed? Insights welcome.
