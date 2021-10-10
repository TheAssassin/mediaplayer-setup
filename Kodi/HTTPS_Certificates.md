# HTTPS Certificates

Apparently LibreELEC (and probably other OSes running KODI on embedded devices) [is not doing a good job at updating TLS certificates](https://forum.libreelec.tv/thread/24259-would-you-please-be-so-nice-and-finally-fix-the-issue-with-certificates/) which are needed for https, and there appears to be no easy way to disable https certificate checking.

As a result, addons cannot be updated anymore, the TV EPG stops working, etc.

Combine this with the fact that KODI unfortunately does not show clear-text error messages on screen you can figure out what is going on only by sshing into the box and inspecting the log file using `cat /storage/.kodi/temp/kodi.log`.

This __works__:

```
# This is needed so that curl can run
wget https://curl.se/ca/cacert.pem -O /run/libreelec/cacert.pem

# Now use curl to make it permanent (and to test that libcurl can use the certificates)
curl "https://curl.se/ca/cacert.pem" > /storage/.config/cacert.pem

# Make it survive a reboot
cat >> ~/.config/autostart.sh <<\EOF
cp /storage/.config/cacert.pem /run/libreelec/
EOF
chmod +x ~/.config/autostart.sh
```

More information:
https://curl.se/docs/caextract.html
