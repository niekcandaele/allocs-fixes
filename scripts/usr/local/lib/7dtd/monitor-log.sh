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


. /usr/local/lib/7dtd/common.sh
. /usr/local/lib/7dtd/playerlog.sh

if [ $(isValidInstance $1) -eq 0 ]; then
	echo "No instance given or not a valid instance!"
	return
fi

INSTANCE=$1
LOGTIMESTAMP=$2
LOG=$(getInstancePath $INSTANCE)/logs/${LOGTIMESTAMP}_output_log.txt
CHATLOG=$(getInstancePath $INSTANCE)/logs/${LOGTIMESTAMP}_chat.log
COMMANDLOG=$(getInstancePath $INSTANCE)/logs/${LOGTIMESTAMP}_commandExecution.log

timestamp() {
	date '+%Y.%m.%d %H:%M:%S'
}

handleConnect() {
	local entityId="$1"
	local name="$2"
	local steamId="$3"
	local ip="$4"
	local ownerId="$5"
	
	logPlayerConnect $INSTANCE "$entityId" "$name" "$steamId" "$ip" "$ownerId"

	for H in $(getHooksFor playerConnect $INSTANCE); do
		$H $INSTANCE "$entityId" "$name" "$steamId" "$ip" "$ownerId"
	done
}

handleDisconnect() {
	local playerId="$1"
	local entityId="$2"

	logPlayerDisconnect $INSTANCE "$entityId"

	for H in $(getHooksFor playerDisconnect $INSTANCE); do
		$H $INSTANCE "$playerId" "$entityId" "$NICKNAME" "$STEAMID"
	done
}

handlePlayerSpawnedInWorld() {
	local entityId="$1"
	local playerId="$2"
	local ownerId="$3"
	local playerName="$4"
	local reason="$5"
	local position="$6"
	
	for H in $(getHooksFor playerSpawned $INSTANCE); do
		$H $INSTANCE "$entityId" "$playerId" "$ownerId" "$playerName" "$reason" "$position"
	done
}

handleChat() {
	echo "$(timestamp): $1: $2 (SteamID $3, EntityID $4, Target $5)" >> $CHATLOG
	
	for H in $(getHooksFor chat $INSTANCE); do
		$H $INSTANCE "$1" "$2" "$3" "$4" "$5"
	done
}

handleGmsg() {
	echo "$(timestamp): GMSG: $1" >> $CHATLOG
	
	for H in $(getHooksFor gmsg $INSTANCE); do
		$H $INSTANCE "$1"
	done
}

handleRemoteCommand() {
	local cmd="$1"
	local name="$2"
	
	echo "$(timestamp): Player \"$name\" executed \"$cmd\"" >> $COMMANDLOG

	for H in $(getHooksFor remoteCommand $INSTANCE); do
		$H $INSTANCE "$cmd" "$name"
	done
}

handleTelnetCommand() {
	local cmd="$1"
	local ip="$2"

	echo "$(timestamp): Telnet from \"$ip\" executed \"$cmd\"" >> $COMMANDLOG

	for H in $(getHooksFor telnetCommand $INSTANCE); do
		$H $INSTANCE "$cmd" "$ip"
	done
}


if [ ! -d "$(getInstancePath $INSTANCE)/logs" ]; then
	mkdir "$(getInstancePath $INSTANCE)/logs"
fi

setAllPlayersOffline

rm $(getInstancePath $INSTANCE)/logs/current_output_log.txt
rm $(getInstancePath $INSTANCE)/logs/current_chat.log
rm $(getInstancePath $INSTANCE)/logs/current_commandExecution.log
ln -s $LOG $(getInstancePath $INSTANCE)/logs/current_output_log.txt
ln -s $CHATLOG $(getInstancePath $INSTANCE)/logs/current_chat.log
ln -s $COMMANDLOG $(getInstancePath $INSTANCE)/logs/current_commandExecution.log

sleep 5

NOBUF="stdbuf -e0 -o0"

$NOBUF tail -n 5000 -F $LOG |
$NOBUF tr '\\' '/' |
$NOBUF tr -d '\r' |
$NOBUF grep -v "^(Filename: " |
$NOBUF sed -r 's/^[0-9]+-[0-9]+-[0-9]+T[0-9]+:[0-9]+:[0-9]+ [0-9]+[.,][0-9]+ [A-Z]+ (.*)$/\1/' |
while read line ; do
	if [ -n "$line" ]; then
		#Player connected, entityid=1278, name=termo2, steamid=76561197997439820, steamOwner=76561197997439820, ip=178.203.27.140 
		#Player connected, entityid=[0-9]*, name=.*, steamid=[0-9]*, steamOwner=[0-9]*, ip=[a-fA-F:0-9.]*$ 
		if [ -n "$(echo "$line" | grep '^Player connected,')" ]; then
			entityId=$(expr "$line" : 'Player connected, entityid=\([0-9]*\), name=.*, steamid=[0-9]*, steamOwner=[0-9]*, ip=[a-fA-F:0-9.]*$')
			playerName=$(expr "$line" : 'Player connected, entityid=[0-9]*, name=\(.*\), steamid=[0-9]*, steamOwner=[0-9]*, ip=[a-fA-F:0-9.]*$')
			steamId=$(expr "$line" : 'Player connected, entityid=[0-9]*, name=.*, steamid=\([0-9]*\), steamOwner=[0-9]*, ip=[a-fA-F:0-9.]*$')
			steamOwner=$(expr "$line" : 'Player connected, entityid=[0-9]*, name=.*, steamid=[0-9]*, steamOwner=\([0-9]*\), ip=[a-fA-F:0-9.]*$')
			ip=$(expr "$line" : 'Player connected, entityid=[0-9]*, name=.*, steamid=[0-9]*, steamOwner=[0-9]*, ip=\([a-fA-F:0-9.]*\)$')
			sleep 1
			handleConnect "$entityId" "$playerName" "$steamId" "$ip" "$steamOwner"
			unset entityId playerName steamId steamOwner ip
		#Player disconnected: EntityID=[0-9]*, PlayerID='[0-9]*', OwnerID='[0-9]*', PlayerName='.*'$ 
		elif [ -n "$(echo "$line" | grep '^Player disconnected: ')" ]; then 
			playerId=$(expr "$line" : "Player disconnected: EntityID=[0-9]*, PlayerID='\([0-9]*\)', OwnerID='[0-9]*', PlayerName='.*'$") 
			entityId=$(expr "$line" : "Player disconnected: EntityID=\([0-9]*\), PlayerID='[0-9]*', OwnerID='[0-9]*', PlayerName='.*'$") 
			handleDisconnect "$playerId" "$entityId"
			unset playerId entityId
		#PlayerSpawnedInWorld (reason: .+, position: [0-9]+, [0-9]+, [0-9]+): EntityID=[0-9]+, PlayerID='[0-9]+', OwnerID='[0-9]+', PlayerName='.*'
		elif [ -n "$(echo "$line" | grep '^PlayerSpawnedInWorld ')" ]; then
			reason=$(expr "$line" : "PlayerSpawnedInWorld (reason: \(.+\), position: [0-9]+, [0-9]+, [0-9]+): EntityID=[0-9]+, PlayerID='[0-9]+', OwnerID='[0-9]+', PlayerName='.*'$") 
			position=$(expr "$line" : "PlayerSpawnedInWorld (reason: .+, position: \([0-9]+, [0-9]+, [0-9]+\)): EntityID=[0-9]+, PlayerID='[0-9]+', OwnerID='[0-9]+', PlayerName='.*'$") 
			entityId=$(expr "$line" : "PlayerSpawnedInWorld (reason: .+, position: [0-9]+, [0-9]+, [0-9]+): EntityID=\([0-9]+\), PlayerID='[0-9]+', OwnerID='[0-9]+', PlayerName='.*'$") 
			playerId=$(expr "$line" : "PlayerSpawnedInWorld (reason: .+, position: [0-9]+, [0-9]+, [0-9]+): EntityID=[0-9]+, PlayerID='\([0-9]+\)', OwnerID='[0-9]+', PlayerName='.*'$") 
			ownerId=$(expr "$line" : "PlayerSpawnedInWorld (reason: .+, position: [0-9]+, [0-9]+, [0-9]+): EntityID=[0-9]+, PlayerID='[0-9]+', OwnerID='\([0-9]+\)', PlayerName='.*'$") 
			playerName=$(expr "$line" : "PlayerSpawnedInWorld (reason: .+, position: [0-9]+, [0-9]+, [0-9]+): EntityID=[0-9]+, PlayerID='[0-9]+', OwnerID='[0-9]+', PlayerName='\(.*\)'$") 
			handlePlayerSpawnedInWorld "$entityId" "$playerId" "$ownerId" "$playerName" "$reason" "$position"
			unset reason position entityId playerId ownerId playerName
		#GMSG: .*$
		elif [ -n "$(echo "$line" | grep -E '^GMSG: .+')" ]; then
			msg=$(expr "$line" : 'GMSG: \(.*\)$')
			handleGmsg "$msg"
			unset msg
		#Chat (from '<steamid>', entity id '<entityid>', to '<targettype>'): '<senderchatname>': <msg>
		elif [ -n "$(echo "$line" | grep -E '^Chat .+')" ]; then
			steamId=$(expr "$line" : "Chat (from '\(.+\)', entity id '[0-9]+', to '[a-fA-F:0-9.]+'): '.*': .*$") 
			entityId=$(expr "$line" : "Chat (from '.+', entity id '\([0-9]+\)', to '[a-fA-F:0-9.]+'): '.*': .*$") 
			targetType=$(expr "$line" : "Chat (from '.+', entity id '[0-9]+', to '\([a-fA-F:0-9.]+\)'): '.*': .*$") 
			name=$(expr "$line" : "Chat (from '.+', entity id '[0-9]+', to '[a-fA-F:0-9.]+'): '\(.*\)': .*$") 
			msg=$(expr "$line" : "Chat (from '.+', entity id '[0-9]+', to '[a-fA-F:0-9.]+'): '.*': \(.*\)$") 
			handleChat "$name" "$msg" "$steamId" "$entityId" "$targetType"
			unset name msg steamId entityId targetType
		#Executing command ".*" from client ".*"$ 
		elif [ -n "$(echo "$line" | grep '^Executing command '.*' from client')" ]; then 
			cmd=$(expr "$line" : "Executing command '\(.*\)' from client .*$") 
			nick=$(expr "$line" : "Executing command '.*' from client \(.*\)$") 
			handleRemoteCommand "$cmd" "$nick"
			unset cmd nick
		#Executing command ".*" by Telnet from .*$ 
		elif [ -n "$(echo "$line" | grep '^Executing command '.*' by Telnet from ')" ]; then 
			cmd=$(expr "$line" : "Executing command '\(.*\)' by Telnet from .*$") 
			ip=$(expr "$line" : "Executing command '.*' by Telnet from \(.*\)$") 
			handleTelnetCommand "$cmd" "$ip"
			unset cmd ip
		fi
	fi
done
