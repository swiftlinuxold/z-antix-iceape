#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit
fi

USERNAME=$(logname)
IS_CHROOT=0

# The remastering process uses chroot mode.
# Check to see if this script is operating in chroot mode.
# If /home/$USERNAME exists, then we are not in chroot mode.
if [ -d "/home/$USERNAME" ]; then
	IS_CHROOT=0
	DIR_DEVELOP=/home/$USERNAME/develop # not in chroot mode
else
	IS_CHROOT=1
	DIR_DEVELOP=/usr/local/bin/develop # in chroot mode
fi

echo "CHANGING ICEAPE BROWSER SETTINGS"

# Disable IPv6 for more speed
echo "Replacing /usr/share/iceape/greprefs/all.js"
rm /usr/share/iceape/greprefs/all.js
FILE_TO_COPY=$DIR_DEVELOP/iceape/usr_share_iceape_greprefs/all.js
cp $FILE_TO_COPY /usr/share/iceape/greprefs
chown root:root /usr/share/iceape/greprefs/all.js

# Do not switch to new tabs
# Open links meant to open a new window in a new tab instead
# Automatically remove private data upon closing the browser but offer the option to retain it
echo "Replacing /usr/share/iceape/defaults/pref/browser-prefs.js"
rm /usr/share/iceape/defaults/pref/browser-prefs.js
FILE_TO_COPY=$DIR_DEVELOP/iceape/usr_share_iceape_defaults_pref/browser-prefs.js
cp $FILE_TO_COPY /usr/share/iceape/defaults/pref
chown root:root /usr/share/iceape/defaults/pref/browser-prefs.js

# Replace bookmarks
echo "Replacing /usr/share/iceape/defaults/profile/bookmarks.html"
rm /usr/share/iceape/defaults/profile/bookmarks.html
FILE_TO_COPY=$DIR_DEVELOP/iceape/usr_share_iceape_defaults_profile/bookmarks.html
cp $FILE_TO_COPY /usr/share/iceape/defaults/profile
if [ $IS_CHROOT -eq 0 ]; then
    chown $USERNAME:users /usr/share/iceape/defaults/profile/bookmarks.html
else
	chown demo:users /usr/share/iceape/defaults/profile/bookmarks.html
fi

echo "Replacing /home/(username)/.mozilla/seamonkey/*.default/bookmarks.html"
if [ $IS_CHROOT -eq 0 ]; then
    rm /home/$USERNAME/.mozilla/seamonkey/*.default/bookmarks.html
	cp  $FILE_TO_COPY /home/$USERNAME/.mozilla/seamonkey/*.default
	chown $USERNAME:users /home/$USERNAME/.mozilla/seamonkey/*.default/bookmarks.html
fi



