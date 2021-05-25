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


# Checks for newer scripts version and downloads them

sdtdCommandUpdatescripts() {
	local LOCAL=$(cat /usr/local/lib/7dtd/VERSION | grep "Version" | cut -d\  -f2)
	local REMOTE=$(wget -qO- http://illy.bz/fi/7dtd/VERSION | grep "Version" | cut -d\  -f2)
	
	local LOCAL_BUILD=$(getLocalEngineVersion)
	
	local FORCED
	if [ "$1" = "--force" ]; then
		FORCED=yes
	else
		FORCED=no
	fi
	if [ "$FORCED" = "yes" -o $REMOTE -gt $LOCAL ]; then
		echo "A newer version of the scripts is available."
		echo "Local:     v.$LOCAL"
		echo "Available: v.$REMOTE"
		echo
		echo "Please check the release notes before continuing:"
		echo "  https://7dtd.illy.bz/wiki/Release%20Notes"
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
		
		wget -q http://illy.bz/fi/7dtd/management_scripts.tar.gz -O /tmp/management_scripts.tar.gz
		rm -f /usr/local/lib/7dtd/VERSION /usr/local/lib/7dtd/*.sh /usr/local/lib/7dtd/commands/* /usr/local/bin/7dtd.sh
		TMPPATH=`mktemp -d`
		tar --touch --no-overwrite-dir -xzf /tmp/management_scripts.tar.gz -C $TMPPATH
		cd $TMPPATH
		for SRCFILE in `find * -type f`; do
			if [[ $SRCFILE != etc* ]] || [[ $SRCFILE == etc/bash_completion+ ]]; then
				DESTFOLDER=/`dirname $SRCFILE`
				mkdir -p $DESTFOLDER
				cp -a $SRCFILE $DESTFOLDER/
			fi
		done
		rm -R $TMPPATH

#		chown root.root /etc/init.d/7dtd.sh
		chown root.root /etc/bash_completion.d/7dtd
		chown root.root /usr/local/bin/7dtd.sh
		chown root.root /usr/local/lib/7dtd -R
#		chmod 0755 /etc/init.d/7dtd.sh
		chmod 0755 /etc/bash_completion.d/7dtd
		chmod 0755 /usr/local/bin/7dtd.sh
		chmod 0755 /usr/local/lib/7dtd -R
		
		if [ -d $SDTD_BASE/engine ]; then
			if [ -d /usr/local/lib/7dtd/server-fixes ]; then
				cp /usr/local/lib/7dtd/server-fixes/* $SDTD_BASE/engine/ -R
				chown $SDTD_USER.$SDTD_GROUP -R $SDTD_BASE/engine/
			fi
		fi

		echo "Update done."
		echo
		echo "Note: This updated only script files. If the global config file"
		echo "/etc/7dtd.conf contains changes for the newer version or there"
		echo "were new files added to the user folder /home/sdtd those changes"
		echo "have not been applied!"
	else
		echo "Scripts are already at the newest version (v.$LOCAL)."
	fi
}

sdtdCommandUpdatescriptsHelp() {
	echo "Usage: $(basename $0) updatescripts [--force]"
	echo
	echo "Check for a newer version of the management scripts. If there is a newer"
	echo "version they can be updated by this command."
	echo
	echo "If --force is specified you are asked if you want to redownload the scripts"
	echo "even if there is no new version available."
}

sdtdCommandUpdatescriptsDescription() {
	echo "Update these scripts"
}

sdtdCommandUpdatescriptsExpects() {
	case $1 in
		2)
			echo "--force"
			;;
	esac
}

