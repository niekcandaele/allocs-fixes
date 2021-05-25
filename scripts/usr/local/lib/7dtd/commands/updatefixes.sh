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


# Checks for newer server fixes version and downloads them

sdtdCommandUpdatefixes() {
	if [ -d /usr/local/lib/7dtd/server-fixes ]; then
		local LOCAL=$(cat /usr/local/lib/7dtd/server-fixes/Mods/Allocs_CommonFunc/7dtd-server-fixes_version.txt | grep -v "Combined")
	else
		local LOCAL="None"
	fi
	local REMOTE=$(wget -qO- http://illy.bz/fi/7dtd/7dtd-server-fixes_version.txt | grep -v "Combined")
	
	local FORCED
	if [ "$1" = "--force" ]; then
		FORCED=yes
	else
		FORCED=no
	fi
	if [ "$FORCED" = "yes" -o "$REMOTE" != "$LOCAL" ]; then
		echo "A newer version of the server fixes is available."
		echo "Local:"
		echo "$LOCAL"
		echo
		echo "Available:"
		echo "$REMOTE"
		echo
		echo "Please check the release notes before continuing:"
		echo "  https://7dtd.illy.bz/wiki/Server%20fixes#ReleaseNotes"
		echo
		
		while : ; do
			local CONTINUE
			read -p "Continue? (yn) " CONTINUE
			case $CONTINUE in
				y)
					echo "Updating..."
					break
					;;
				n)
					echo "Canceled"
					return
					;;
				*)
					echo "Wrong input"
			esac
		done
		
		wget -q http://illy.bz/fi/7dtd/server_fixes.tar.gz -O /tmp/server_fixes.tar.gz
		rm -Rf /usr/local/lib/7dtd/server-fixes
		mkdir /usr/local/lib/7dtd/server-fixes
		tar --touch --no-overwrite-dir -xzf /tmp/server_fixes.tar.gz -C /usr/local/lib/7dtd/server-fixes

		if [ -d $SDTD_BASE/engine ]; then
			if [ -d /usr/local/lib/7dtd/server-fixes ]; then
				cp /usr/local/lib/7dtd/server-fixes/* $SDTD_BASE/engine/ -R
				chown $SDTD_USER.$SDTD_GROUP -R $SDTD_BASE/engine/
			fi
		fi

		echo "Update done."
	else
		echo "Server fixes are already at the latest version:"
		echo "$LOCAL"
	fi
}

sdtdCommandUpdatefixesHelp() {
	echo "Usage: $(basename $0) updatefixes [--force]"
	echo
	echo "Check for a newer version of the server fixes. If there is a newer"
	echo "version they can be installed/updated by this command."
	echo
	echo "If --force is specified you are asked if you want to redownload the fixes"
	echo "even if there is no new version available."
}

sdtdCommandUpdatefixesDescription() {
	echo "Install/Update the server fixes"
}

sdtdCommandUpdatefixesExpects() {
	case $1 in
		2)
			echo "--force"
			;;
	esac
}

