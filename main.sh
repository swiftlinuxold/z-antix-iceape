#!/bin/bash
# Proper header for a Bash script.

# Check for root user login
if [ ! $( id -u ) -eq 0 ]; then
	echo "You must be root to run this script."
	echo "Please enter su before running this script again."
	exit 2
fi

IS_CHROOT=0 # changed to 1 if and only if in chroot mode
USERNAME=""
DIR_DEVELOP=""

# The remastering process uses chroot mode.
# Check to see if this script is operating in chroot mode.
# /srv directory only exists in chroot mode
if [-d "/srv"]; then
	IS_CHROOT=1 # in chroot mode
	DIR_DEVELOP=/usr/local/bin/develop 
else
	USERNAME=$(logname) # not in chroot mode
	DIR_DEVELOP=/home/$USERNAME/develop 
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

if [ $IS_CHROOT -eq 0 ]; then
	echo "Replacing /home/(username)/.mozilla/seamonkey/*.default/bookmarks.html"
    rm /home/$USERNAME/.mozilla/seamonkey/*.default/bookmarks.html
	cp  $FILE_TO_COPY /home/$USERNAME/.mozilla/seamonkey/*.default
	chown $USERNAME:users /home/$USERNAME/.mozilla/seamonkey/*.default/bookmarks.html
fi

# Run ad-blocker
# Note that the script here is the original with the zenity commands deactivated.
# Zenity does not work in chroot mode.
bash $DIR_DEVELOP/iceape/block-advert.sh

exit 0
