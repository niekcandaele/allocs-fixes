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


# Provides common functions for 7dtd-scripts. Not intended to be run directly.

# Check if the script is run as root (exit otherwise) and load global config
checkRootLoadConf() {
	if [ `id -u` -ne 0 ]; then
		echo "This script has to be run as root!"
		exit 10
	fi
	. /etc/7dtd.conf
}

# Get the config path for the given instance
# Params:
#   1: Instance name
# Returns:
#   Config path for instance
getInstancePath() {
	echo $SDTD_BASE/instances/$1
}

# Check if the given instance name is valid (no blanks, no special chars,
# only letters, digits, underscore, hyphen -> [A-Za-z0-9_\-])
# Params:
#   1: Instance name
# Returns:
#   0/1 instance not valid/valid
isValidInstanceName() {
	if [[ "$1" =~ ^[A-Za-z0-9_\-]+$ ]]; then
		echo 1
	else
		echo 0
	fi
}

# Check if the given instance name is an existing instance
# Params:
#   1: Instance name
# Returns:
#   0/1 instance not valid/valid
isValidInstance() {
	if [ ! -z "$1" ]; then
		if [ $(isValidInstanceName "$1") -eq 1 ]; then
			if [ -d $(getInstancePath "$1") ]; then
				if [ -f $(getInstancePath "$1")/config.xml ]; then
					echo 1
					return
				fi
			fi
		fi
	fi
	echo 0
}

# Check if the given instance is currently running
# Params:
#   1: Instance name
# Returns:
#   0 = not running
#   1 = running
isRunning() {
	$SSD --status --pidfile $(getInstancePath $1)/7dtd.pid
	if [ $? -eq 0 ]; then
		echo 1
	else
		echo 0
	fi
}

# Get list of defined instances
# Returns:
#   List of instances
getInstanceList() {
	local IF
	for IF in $SDTD_BASE/instances/*; do
		local I=`basename $IF`
		if [ $(isValidInstance $I) -eq 1 ]; then
			echo $I
		fi
	done
}

# Get the PID of the instance if it is running, 0 otherwise
# Params:
#   1: Instance name
# Returns:
#   0 if not running
#   PID otherwise
getInstancePID() {
	if [ $(isRunning $1) -eq 1 ]; then
		cat $(getInstancePath $1)/7dtd.pid
	else
		echo 0
	fi
}

# Get the installed branch name
# Returns:
#   "public" if no engine installed or no appmanifest found or buildid could not be read
#   Branch name
getLocalBranch() {
	local APPMANIFEST=$(find $SDTD_BASE/engine -type f -name "appmanifest_294420.acf")
	local LOCAL="public"
	if [ -f "$APPMANIFEST" ]; then
		LOCAL=$(grep betakey "$APPMANIFEST" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)
		if [[ -z $LOCAL ]]; then
			LOCAL="public"
		else
			echo $LOCAL
			return
		fi
	fi
	echo $LOCAL
}

# Get the local engine version number (i.e. build id)
# Returns:
#   0 if no engine installed or no appmanifest found or buildid could not be read
#   Build Id otherwise
getLocalEngineVersion() {
	local APPMANIFEST=$(find $SDTD_BASE/engine -type f -name "appmanifest_294420.acf")
	local LOCAL=0
	if [ -f "$APPMANIFEST" ]; then
		LOCAL=$(grep buildid "$APPMANIFEST" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)
		if [ $(isANumber "$LOCAL") -eq 0 ]; then
			LOCAL=0
		fi
	fi
	echo $LOCAL
}

# Get the local engine update time
# Returns:
#   0 if no engine installed or no appmanifest found or buildid could not be read
#   Update time otherwise
getLocalEngineUpdateTime() {
	local APPMANIFEST=$(find $SDTD_BASE/engine -type f -name "appmanifest_294420.acf")
	local LOCAL=0
	if [ -f "$APPMANIFEST" ]; then
		LOCAL=$(grep LastUpdated "$APPMANIFEST" | tr '[:blank:]"' ' ' | tr -s ' ' | cut -d\  -f3)
		if [ $(isANumber "$LOCAL") -eq 0 ]; then
			LOCAL=0
		else
			date --date="@${LOCAL}" "+%Y-%m-%d %H:%M:%S"
			return
		fi
	fi
	echo $LOCAL
}

# Check if a given port range (baseport, baseport+1, baseport+2 each udp)
# is already in use by any other instance
# Params:
#   1: Baseport
#   2: Current instance (ignored)
# Returns:
#   0/1 not in use/in use
checkGamePortUsed() {
	local PORTMIN=$1
	local PORTMAX=$(( $1 + 2 ))
	local I
	for I in $(getInstanceList); do
		if [ "$2" != "$I" ]; then
			local CURPORTMIN=$(getConfigValue $I "ServerPort")
			local CURPORTMAX=$(( $CURPORTMIN + 2 ))
			if [ $PORTMAX -ge $CURPORTMIN -a $PORTMIN -le $CURPORTMAX ]; then
				echo 1
				return
			fi
		fi
	done
	echo 0
}

# Check if a given TCP port is already in use by any instance (either by control
# panel or telnet)
# Params:
#   1: Port
# Returns:
#   0/1 not in use/in use
checkTCPPortUsed() {
	local I
	for I in $(getInstanceList); do
		if [ "$2" != "$I" ]; then
			local CURENABLED=$(getConfigValue $I "TelnetEnabled")
			local CURPORT=$(getConfigValue $I "TelnetPort")
			if [ "$CURENABLED" = "true" -a $CURPORT -eq $1 ]; then
				echo 1
				return
			fi
			CURENABLED=$(getConfigValue $I "ControlPanelEnabled")
			CURPORT=$(getConfigValue $I "ControlPanelPort")
			if [ "$CURENABLED" = "true" -a $CURPORT -eq $1 ]; then
				echo 1
				return
			fi
		fi
	done
	echo 0
}

# Send a single command to the telnet port
# Params:
#   1: Instance name
#   2: Command
#   3: (Optional) Timeout in sec, defaulting to 1
# Returns:
#   String of telnet output
telnetCommand() {
	local TEL_ENABLED=$(getConfigValue $1 TelnetEnabled)
	local TEL_PORT=$(getConfigValue $1 TelnetPort)
	local TEL_PASS=$(getConfigValue $1 TelnetPassword)	
	if [ "$TEL_ENABLED" = "true" ]; then
		local TEMPFILE=$(mktemp)
		rm -f $TEMPFILE
		mkfifo $TEMPFILE
		exec 3<> $TEMPFILE
		nc 127.0.0.1 $TEL_PORT <&3 &
		local NCPID=$!
		disown
		if [ -n "$TEL_PASS" ]; then
			printf "$TEL_PASS\n$2\n" >&3
		else
			printf "$2\n" >&3
		fi
		sleep ${3:-1}
		printf "exit\n" >&3
		sleep 0.2
		kill -9 $NCPID > /dev/null 2>&1
		exec 3>&-
		rm -f $TEMPFILE
	else
		echo "Telnet not enabled."
	fi
}

# Get all hook files for the given hook-name
# Params:
#   1: Hook name
#   2: Instance name
# Returns:
#   Names of hook files
getHooksFor() {
	if [ -n "$2" ]; then
		if [ -d $(getInstancePath $2)/hooks/$1 ]; then
			local H
			for H in $(getInstancePath $2)/hooks/$1/*.sh; do
				echo "$H"
			done
		fi
	fi
	if [ -d $SDTD_BASE/hooks/$1 ]; then
		local H
		for H in $SDTD_BASE/hooks/$1/*.sh; do
			echo "$H"
		done
	fi
}

# Lowercase passed string
# Params:
#   1: String
# Returns:
#   Lowercased string
lowercase() {
	echo "${1}" | tr "[:upper:]" "[:lower:]"
}

# Prepare passed string as part of camelcase, i.e. first char upper case, others
# lowercase
# Params:
#   1: String
# Returns:
#   Transformed string
camelcasePrep() {
	echo $(echo "${1:0:1}" | tr "[:lower:]" "[:upper:]")$(echo "${1:1}" | tr "[:upper:]" "[:lower:]")
}

# Check if given value is a (integer) number
# Params:
#   1: Value
# Returns:
#   0/1 for NaN / is a number
isANumber() {
	if [[ $1 =~ ^[0-9]+$ ]] ; then
		echo "1"
	else
		echo "0"
	fi
}

# Check if given value is a boolean (true/false, yes/no, y/n)
# Params:
#   1: Value
# Returns:
#   0/1
isABool() {
	local LOW=$(lowercase "$1")
	if [ "$LOW" = "false" -o "$LOW" = "true"\
		-o "$LOW" = "yes" -o "$LOW" = "y"\
		-o "$LOW" = "no" -o "$LOW" = "n" ]; then
		echo 1
	else
		echo 0
	fi
}

# Convert the given value to a boolean 0/1
# Params:
#   1: Value
# Returns:
#   0/1 as false/true
getBool() {
	if [ $(isABool "$1") -eq 0 ]; then
		echo 0
	else
		local LOW=$(lowercase "$1")
		if [ "$LOW" = "true" -o "$LOW" = "yes" -o "$LOW" = "y" ]; then
			echo 1
		else
			echo 0
		fi
	fi
}

listCommands() {
	local C
	for C in $(declare -F | cut -d\  -f3 | grep "^sdtdCommand"\
			| grep -v "Help$"\
			| grep -v "Description$"\
			| grep -v "Expects$"); do
		local CMD=$(lowercase "${C#sdtdCommand}")
		printf "%s " "$CMD"
	done
}

. /usr/local/lib/7dtd/help.sh
. /usr/local/lib/7dtd/serverconfig.sh
for M in /usr/local/lib/7dtd/commands/*.sh; do
	. $M
done

checkRootLoadConf

