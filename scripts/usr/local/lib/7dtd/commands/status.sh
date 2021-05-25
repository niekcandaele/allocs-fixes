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



# Print status of given instance.

sdtdCommandStatus() {
	if [ $(isValidInstance $1) -eq 0 ]; then
		echo "No instance given or not a valid instance!"
		return
	fi

	line() {
		printf "    %-*s %s\n" 15 "$1" "$2"
	}
	
	echo "Instance: $1"
	echo

	if [ $(isRunning $1) -eq 1 ]; then
		echo "Status: Running"
		echo "Open ports:"
		netstat -nlp | grep $(getInstancePID $1) | sed -r 's/^([^ ]*)\s+.*[^ :]*:([^ ]*).*[^ :]*:[^ ]*.*/    \2 (\1)/g' | sort
		cur=$(telnetCommand $1 lp | grep -aE "^\s?Total of " | cut -d\  -f 3)
		echo "Players: $cur"
	else
		echo "Status: NOT running"
	fi

	echo
	echo "Game info:"
	line "Server name:" "$(getConfigValue $1 ServerName)"
	line "Password:" "$(getConfigValue $1 ServerPassword)"
	line "Max players:" "$(getConfigValue $1 ServerMaxPlayerCount)"
	line "World:" "$(getConfigValue $1 GameWorld)"

	echo
	echo "Network info:"
	line "Port:" "$(getConfigValue $1 ServerPort)"
	line "Public:" "$(getConfigValue $1 ServerIsPublic)"
	if [ "$(getConfigValue $1 ControlPanelEnabled)" = "false" ]; then
		cp="off"
	else
		cp="Port $(getConfigValue $1 ControlPanelPort), Pass $(getConfigValue $1 ControlPanelPassword)"
	fi
	line "Control Panel:" "$cp"
	if [ "$(getConfigValue $1 TelnetEnabled)" = "false" ]; then
		tn="off"
	else
		tn="Port $(getConfigValue $1 TelnetPort), Pass $(getConfigValue $1 TelnetPassword)"
	fi
	line "Telnet:" "$tn"

	echo
}

sdtdCommandStatusHelp() {
	echo "Usage: $(basename $0) status <instance>"
	echo
	echo "Print status information for the given instance."
}

sdtdCommandStatusDescription() {
	echo "Print status for the given instance"
}

sdtdCommandStatusExpects() {
	case $1 in
		2)
			getInstanceList
			;;
	esac
}

