#!/bin/bash

#   Copyright 2016 Christian 'Alloc' Illy
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.


PLAYERSXML=$(getInstancePath $1)/players.xml
PLAYERSLOG=$(getInstancePath $1)/logs/$(date '+%Y-%m-%d_%H-%M-%S')_players.log

timestamp() {
	date '+%Y.%m.%d %H:%M:%S'
}

# Create empty player list if not existing
createPlayerList() {
	if [ ! -f "$PLAYERSXML" ]; then
		echo "<Players/>" > $PLAYERSXML
	fi
	if [ -z "$(cat $PLAYERSXML)" ]; then
		echo "<Players/>" > $PLAYERSXML
	fi
}

# Set all players for an instance to offline (on startup/shutdown)
setAllPlayersOffline() {
	createPlayerList
	$XMLSTARLET ed -L \
		-u "/Players/Player/@online" -v "false" \
		"$PLAYERSXML"
	rm $(getInstancePath $INSTANCE)/logs/current_players.log
	ln -s $PLAYERSLOG $(getInstancePath $INSTANCE)/logs/current_players.log
}

# Handle a player connect for logging/tracking
# Params:
#   1: Instance name
#   2: Entity ID
#   3: Steam ID
#   4: Nick name
#   5: IP
#   6: Steam Owner ID
logPlayerConnect() {
	local ENTITYID="$2"
	local NICKNAME="$3"
	local STEAMID="$4"
	local IP="$5"
	local OWNERID="$6"

	echo "$(timestamp) +++ $ENTITYID $NICKNAME $STEAMID $IP $OWNERID" >> "$PLAYERSLOG"

	createPlayerList
	
	XPATHBASE="/Players/Player[@steamid='$STEAMID']"

	if [ -z $($XMLSTARLET sel -t -v "$XPATHBASE/@steamid" "$PLAYERSXML") ]; then
		$XMLSTARLET ed -L \
			-s "/Players" -t elem -n "Player" -v "" \
			-i "/Players/Player[not(@steamid)]" -t attr -n "steamid" -v "$STEAMID" \
			-i "$XPATHBASE" -t attr -n "nick" -v "$NICKNAME" \
			-i "$XPATHBASE" -t attr -n "playtime" -v "0" \
			-i "$XPATHBASE" -t attr -n "logins" -v "1" \
			-i "$XPATHBASE" -t attr -n "lastlogin" -v "$(date '+%s')" \
			-i "$XPATHBASE" -t attr -n "online" -v "true" \
			-i "$XPATHBASE" -t attr -n "entityid" -v "$ENTITYID" \
			-i "$XPATHBASE" -t attr -n "lastIp" -v "$IP" \
			-i "$XPATHBASE" -t attr -n "steamOwner" -v "$OWNERID" \
			"$PLAYERSXML"
	else
		LOGINS=$($XMLSTARLET sel -t -v "$XPATHBASE/@logins" "$PLAYERSXML")
		(( LOGINS++ ))
		$XMLSTARLET ed -L \
			-u "$XPATHBASE/@lastlogin" -v "$(date '+%s')" \
			-u "$XPATHBASE/@online" -v "true" \
			-u "$XPATHBASE/@nick" -v "$NICKNAME" \
			-u "$XPATHBASE/@entityid" -v "$ENTITYID" \
			-u "$XPATHBASE/@logins" -v "$LOGINS" \
			-u "$XPATHBASE/@lastIp" -v "$IP" \
			-u "$XPATHBASE/@steamOwner" -v "$OWNERID" \
			"$PLAYERSXML"
	fi
}

# Handle a player disconnect for logging/tracking
# Params:
#   1: Instance name
#   2: Entity ID
logPlayerDisconnect() {
	ENTITYID="$2"

	createPlayerList

	XPATHBASE="/Players/Player[@entityid='$ENTITYID'][@online='true']"

	if [ -f $PLAYERSXML ]; then
		if [ ! -z $($XMLSTARLET sel -t -v "$XPATHBASE/@steamid" "$PLAYERSXML") ]; then
			NICKNAME=$($XMLSTARLET sel -t -v "$XPATHBASE/@nick" "$PLAYERSXML")
			STEAMID=$($XMLSTARLET sel -t -v "$XPATHBASE/@steamid" "$PLAYERSXML")
			LOGINTIME=$($XMLSTARLET sel -t -v "$XPATHBASE/@lastlogin" "$PLAYERSXML")
			PLAYTIME=$($XMLSTARLET sel -t -v "$XPATHBASE/@playtime" "$PLAYERSXML")
			NOW=$(date '+%s')
			PLAYTIME=$(( PLAYTIME + NOW - LOGINTIME ))
			$XMLSTARLET ed -L \
				-u "$XPATHBASE/@playtime" -v "$PLAYTIME" \
				-u "$XPATHBASE/@online" -v "false" \
				"$PLAYERSXML"
		fi
	fi

	echo "$(timestamp) --- $ENTITYID $NICKNAME $STEAMID" >> "$PLAYERSLOG"
}

