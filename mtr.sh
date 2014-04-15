#!/bin/bash

DEST="~/Desktop/land/"
BGCPBUFFER="10"

function getTrackIdList {
	PLAYLISTNAME=$1
	TRACKLISTSEDSTRING="/<key>Name<\/key><string>$PLAYLISTNAME/,/<\/array>/p"
	cat lib.xml | sed -n $TRACKLISTSEDSTRING | grep '<key>Track ID</key>' | awk -F">|<" '{print $7}' | sort -n | uniq
}

function urldecode {
    # Credits to Chris Down
    # https://gist.github.com/cdown

    local url_encoded="${1//+/ }"
    printf '%b' "${url_encoded//%/\x}"
    echo ""
}

function getTrackLocation {
	TRACKID=$1
	TRACKIDSEDSTRING="/<\/key><integer>$TRACKID<\/integer>/,/<\/dict>/p"

	urldecode `cat lib.xml | sed -n $TRACKIDSEDSTRING | grep '<key>Location</key><string>' | awk -F">|<" '{print $7}' | sed 's|file:\/\/localhost||g' | sed 's/\&#38;/\&/g'`
}

TRACKLIST=`getTrackIdList "Subset"`
SINGLE=`echo $TRACKLIST | awk '{ print $3 }'`

#TRACKARR=()

for SINGLE in $TRACKLIST
do
	#TRACKARR+=`getTrackLocation $SINGLE`
	FILE=`getTrackLocation $SINGLE`
	cp "$FILE" $DEST
done

echo "$TRACKARR"