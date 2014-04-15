#!/bin/bash

DEST="/sdcard/Music/"
ADBPATH="/Users/Thomas/Dropbox/ADB/"
BGCPMAX=1

function getTrackIdList {
	PLAYLISTNAME=$1
	TRACKLISTSEDSTRING="/<key>Name<\/key><string>$PLAYLISTNAME/,/<\/array>/p"
	cat lib.xml | sed -n $TRACKLISTSEDSTRING | grep '<key>Track ID</key>' | awk -F">|<" '{print $7}' | sort -n | uniq
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

	urldecode `cat lib.xml | sed -n $TRACKIDSEDSTRING | grep '<key>Location</key><string>' | awk -F">|<" '{print $7}' | sed 's|file:\/\/localhost||g' | sed 's|\&#38;|\&|g'`
}

TRACKLIST=`getTrackIdList "$1"`
SINGLE=`echo $TRACKLIST | awk '{ print $3 }'`


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