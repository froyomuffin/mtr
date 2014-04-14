#!/bin/bash

function getTrackIdList {
	PLAYLISTNAME=$1
	TRACKLISTSEDSTRING="/<key>Name<\/key><string>$PLAYLISTNAME/,/<\/array>/p"
	cat lib.xml | sed -n $TRACKLISTSEDSTRING | grep '<key>Track ID</key>' | awk -F">|<" '{print $7}' | sort -n | uniq
}

function getTrackLocation {
	TRACKID=$1
	echo "meep"
	echo $1
	TRACKIDSEDSTRING="/<\/key><integer>$TRACKID<\/integer>/,/<\/dict>/p"

	cat lib.xml | sed -n $TRACKIDSEDSTRING | grep '<key>Location</key><string>' | awk -F">|<" '{print $7}' | sed 's|file:\/\/localhost||g' | sed 's/%20/\\ /g'
}

TRACKLIST=`getTrackIdList "Send"`
echo "moo"
SINGLE=`echo $TRACKLIST | awk '{ print $3 }'`
echo $SINGLE

getTrackLocation $SINGLE