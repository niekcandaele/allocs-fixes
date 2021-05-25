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



sdtdSubcommandInstancesList() {
	printf "%-*s | %-*s | %-*s | %-*s\n" 20 "Instance name" 8 "Running" 7 "Players" 5 "Port"
	printf -v line "%*s-+-%*s-+-%*s-+-%*s\n" 20 " " 8 " " 7 " " 5 " "
	echo ${line// /-}
	for I in $(getInstanceList); do
		if [ $(isRunning $I) -eq 1 ]; then
			run="yes"
			cur=$(telnetCommand $I lp | grep -aE "^\s?Total of " | cut -d\  -f 3)
		else
			run="no"
			cur="-"
		fi

		if [ -z $cur ]; then
			cur="?"
		fi
		max=$(getConfigValue $I ServerMaxPlayerCount)
		port=$(getConfigValue $I ServerPort)

		printf "%-*s | %*s |   %2s/%2d | %5d\n" 20 "$I" 8 "$run" $cur $max $port
	done
}

sdtdSubcommandInstancesCreate() {
	while : ; do
		readInstanceName
		[ $(isValidInstance "$INSTANCE") -eq 0 ] && break
		echo "Instance name already in use."
		INSTANCE=
	done
	echo
	
	local IPATH=$(getInstancePath "$INSTANCE")
	mkdir -p "$IPATH" 2>/dev/null

	if [ $(configTemplateExists) -eq 1 ]; then
		local USETEMPLATE
		while : ; do
			read -p "Use the config template? [Yn] " USETEMPLATE
			USETEMPLATE=${USETEMPLATE:-Y}
			case $USETEMPLATE in
				y|Y)
					cp $SDTD_BASE/templates/config.xml $IPATH/config.xml
					loadCurrentConfigValues "$INSTANCE"
					break
					;;
				n|N)
					break
					;;
			esac
		done
		echo
	fi
	configEditAll configQueryValue
	echo
	configSetAutoParameters "$INSTANCE"
	echo
	echo "Saving"
	
	if [ ! -f $IPATH/config.xml ]; then
		echo "<ServerSettings/>" > $IPATH/config.xml
	fi
	saveCurrentConfigValues "$INSTANCE"
	if [ -f "$SDTD_BASE/templates/admins.xml" ]; then
		cp "$SDTD_BASE/templates/admins.xml" "$IPATH/"
	fi
	chown -R $SDTD_USER.$SDTD_GROUP $IPATH
	echo "Done"
}

sdtdSubcommandInstancesEdit() {
	if [ $(isValidInstance "$1") -eq 0 ]; then
		echo "No instance given or not a valid instance!"
		return
	fi
		
	if [ $(isRunning "$1") -eq 0 ]; then
		INSTANCE=$1
		loadCurrentConfigValues "$1"

		while : ; do
			echo "What section of the config do you want to edit?"
			local i=0
			local sects=()
			for S in $(listConfigEditFuncs); do
				(( i++ ))
				sects[$i]=$S
				printf "  %2d: %s\n" $i "$S"
			done
			echo
			echo "   W: Save and exit"
			echo "   Q: Exit WITHOUT saving"

			local SEC
			while : ; do
				read -p "Section number: " SEC
				SEC=$(lowercase $SEC)
				if [ $(isANumber $SEC) -eq 1 ]; then
					if [ $SEC -ge 1 -a $SEC -le $i ]; then
						break
					fi
				else
					if [ "$SEC" = "q" -o "$SEC" = "w" ]; then
						break
					fi
				fi
				echo "Not a valid section number!"
			done
			echo
			
			case "$SEC" in
				q)
					echo "Not saving"
					break
					;;
				w)
					configSetAutoParameters "$INSTANCE"
					echo "Saving"
					saveCurrentConfigValues "$1"
					echo "Done"
					break
					;;
				*)
					configEdit${sects[$SEC]} configQueryValue
					echo
			esac
		done
	else
		echo "Instance $1 is currently running. Please stop it first."
	fi
}

sdtdSubcommandInstancesDelete() {
	if [ $(isValidInstance "$1") -eq 0 ]; then
		echo "No instance given or not a valid instance!"
		return
	fi

	if [ $(isRunning "$1") -eq 0 ]; then
		local SECCODE=$(dd if=/dev/urandom bs=1 count=100 2>/dev/null \
			| tr -cd '[:alnum:]' | head -c5)
		local SECCODEIN
		echo
		echo "WARNING: Do you really want to delete the following instance?"
		echo "    $1"
		echo "This will delete all of its configuration and save data."
		echo "If you REALLY want to continue enter the following security code:"
		echo "    $SECCODE"
		echo
		read -p "Security code: " -e SECCODEIN
		if [ "$SECCODE" = "$SECCODEIN" ]; then
			rm -R "$(getInstancePath "$1")"
			echo "Done"
		else
			echo "Security code did not match, aborting."
		fi
	else
		echo "Instance $1 is currently running. Please stop it first."
	fi
}

sdtdSubcommandInstancesPrintConfig() {
	if [ $(isValidInstance "$1") -eq 0 ]; then
		echo "No instance given or not a valid instance!"
		return
	fi
		
	INSTANCE=$1
	loadCurrentConfigValues "$1"

	configEditAll printConfigValue
}

sdtdCommandInstances() {
	SUBCMD=$1
	shift
	case $SUBCMD in
		list)
			sdtdSubcommandInstancesList "$@"
			;;
		create)
			sdtdSubcommandInstancesCreate "$@"
			;;
		edit)
			sdtdSubcommandInstancesEdit "$@"
			;;
		delete)
			sdtdSubcommandInstancesDelete "$@"
			;;
		print_config)
			sdtdSubcommandInstancesPrintConfig "$@"
			;;
		*)
			sdtdCommandInstancesHelp
			;;
	esac
}

sdtdCommandInstancesHelp() {
	line() {
		printf "  %-*s %s\n" 19 "$1" "$2"
	}

	echo "Usage: $(basename $0) instances <subcommand>"
	echo "Subcommands are:"
	line "list" "List all defined instances and their status."
	line "create" "Create a new instance"
	line "edit <instance>" "Edit an existing instance"
	line "delete <instance>" "Delete an existing instance"
}

sdtdCommandInstancesDescription() {
	echo "List all defined instances"
}

sdtdCommandInstancesExpects() {
	case $1 in
		2)
			echo "list create edit delete print_config"
			;;
		3)
			case $2 in
				edit|delete|print_config)
					echo "$(getInstanceList)"
					;;
			esac
			;;
	esac
}

