#!/bin/bash

ADBPATH="/Users/Thomas/Dropbox/ADB/"
LIBPATH="/Users/Thomas/Music/iTunes/iTunes Music Library.xml"
BGCPMAX=1
PLAYLISTNAME=$1
DEST="/sdcard/Music/$PLAYLISTNAME"

function getTrackIdList {
	TRACKLISTSEDSTRING="/<key>Name<\/key><string>$PLAYLISTNAME/,/<\/array>/p"
	cat "$LIBPATH" | sed -n $TRACKLISTSEDSTRING | grep '<key>Track ID</key>' | awk -F">|<" '{print $7}' | sort -n | uniq
}

function urldecode {
    # Credits to Chris Down
    # http://github.com/cdown

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\x}"
    echo ""
}

function getTrackLocation {
	TRACKID=$1
	TRACKIDSEDSTRING="/<\/key><integer>$TRACKID<\/integer>/,/<\/dict>/p"

	urldecode `cat "$LIBPATH" | sed -n $TRACKIDSEDSTRING | grep '<key>Location</key><string>' | awk -F">|<" '{print $7}' | sed 's|file:\/\/localhost||g' | sed 's|\&#38;|\&|g'`
}

TRACKLIST=`getTrackIdList`

SINGLE=`echo $TRACKLIST | awk '{ print $3 }'`

"$ADBPATH"adb shell mkdir $DEST

for SINGLE in $TRACKLIST
do
	FILE=`getTrackLocation $SINGLE`
	BGCPCOUNT=`ps -ef | grep 'adb push' | grep -v grep | wc -l`

	echo ''
	echo $FILE | awk -F'/' '{ print $NF }'
	if [ $BGCPCOUNT -lt $BGCPMAX ]
	then
		echo "in bg"
		"$ADBPATH"adb push "$FILE" $DEST $OP 2> /dev/null &
	else
		echo "in fg"
		"$ADBPATH"adb push "$FILE" $DEST $OP 2> /dev/null
	fi
done

echo "$TRACKARR"