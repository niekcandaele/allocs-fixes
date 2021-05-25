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


# Downloads SteamCMD, downloads/updates the 7dtd engine

sdtdCommandUpdateengine() {
	local FORCED=no
	local CHECKONLY=no
	local SHOWINTERNAL=no
	
	local BRANCHNAME="$(getLocalBranch)"
	local BRANCHPASSWORD=""
	
	while test $# -gt 0; do
		case "$1" in
			--check)
				CHECKONLY=yes
				;;
			--showinternal)
				SHOWINTERNAL=yes
				;;
			--experimental)
				BRANCHNAME="latest_experimental"
				;;
			--stable)
				BRANCHNAME="public"
				;;
			--branch)
				if [ -z "$2" ]; then
					echo "Argument --branch not followed by a branch name. Aborting."
					return
				fi
				BRANCHNAME=$2
				shift
				;;
			--password)
				if [ -z "$2" ]; then
					echo "Argument --password not followed by a branch password value. Aborting."
					return
				fi
				BRANCHPASSWORD=$2
				shift
				;;
			--force)
				FORCED=yes
				;;
		esac
		shift
	done
	
	if [ ! -e $SDTD_BASE/steamcmd ]; then
		mkdir $SDTD_BASE/steamcmd
		cd /tmp
		wget http://media.steampowered.com/installer/steamcmd_linux.tar.gz
		tar -xvzf steamcmd_linux.tar.gz -C $SDTD_BASE/steamcmd
		cd $SDTD_BASE/steamcmd
		./steamcmd.sh +quit
	fi
	
	updateRemoteEngineInfo

	if [ "$CHECKONLY" = "yes" ]; then
		local LOCAL=$(getLocalEngineVersion)
		local REMOTE=$(getBuildId $(getLocalBranch))
		local REMOTETIME=$(getBuildUpdateTime $(getLocalBranch))
		
		echo "Installed:"
		echo "  Build ID:     $(getLocalEngineVersion)"
		echo "  Installed on: $(getLocalEngineUpdateTime)"
		echo "  From branch:  $(getLocalBranch)"
		echo

		echo "Available branches:"
		printf "%-*s | %-*s | %-*s\n" 22 "Branch" 8 "Build ID" 19 "Build set on"
		printf -v line "%*s-+-%*s-+-%*s\n" 22 " " 8 " " 19 " "
		echo ${line// /-}
		for I in $(getBranchNames); do
			if [[ $I != test* ]] || [ "$SHOWINTERNAL" = "yes" ]; then
				local BUILD=$(getBuildId $I)
				local CREATED=$(getBuildUpdateTime $I)
				printf "%-*s | %*s | %2s\n" 22 "$I" 8 "$BUILD" "$CREATED"
			fi
		done | sort -k 3 -n -r
		
		echo
		
		if [ $REMOTE -gt $LOCAL ]; then
			echo "Newer engine version available on the currently installed branch (build id $REMOTE from $REMOTETIME)."
		else
			local MAXREMOTE=0
			local MAXREMOTEBRANCH=0
			local MAXREMOTETIME=0
			for I in $(getBranchNames); do
				if [[ $I != test* ]] || [ "$SHOWINTERNAL" = "yes" ]; then
					local BUILD=$(getBuildId $I)
					local CREATED=$(getBuildUpdateTime $I)
					if [ $BUILD -gt $MAXREMOTE ]; then
						MAXREMOTE=$BUILD
						MAXREMOTETIME=$CREATED
						MAXREMOTEBRANCH=$I
					fi
				fi
			done
			if [ $MAXREMOTE -gt $LOCAL ]; then
				echo "Newer engine version available on the branch \"$MAXREMOTEBRANCH\" (build id $MAXREMOTE from $MAXREMOTETIME)."
			else
				echo "Engine on the latest build."
			fi
		fi
		return
	fi

	for I in $(getInstanceList); do
		if [ $(isRunning $I) -eq 1 ]; then
			echo "At least one instance is still running (\"$I\")."
			echo "Before updating the engine please stop all instances!"
			return
		fi
	done

	local LOCAL=$(getLocalEngineVersion)
	local REMOTE=$(getBuildId $BRANCHNAME)

	if [ "$FORCED" = "yes" -o $REMOTE -gt $LOCAL ]; then
		echo "A newer version of the engine is available."
		echo "Local build id:     $LOCAL (installed on $(getLocalEngineUpdateTime))"
		echo "Available build id: $REMOTE (from $(getBuildUpdateTime $BRANCHNAME))"
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
		
		cd $SDTD_BASE/steamcmd
		local PASSWORDARG=
		if [ -n "$BRANCHPASSWORD" ]; then
			PASSWORDARG=-betapassword $BRANCHPASSWORD
		fi
		#echo ./steamcmd.sh +login anonymous +force_install_dir $SDTD_BASE/engine +app_update 294420 -validate -beta $BRANCHNAME $PASSWORDARG +quit
		./steamcmd.sh +login anonymous +force_install_dir $SDTD_BASE/engine +app_update 294420 -validate -beta $BRANCHNAME $PASSWORDARG +quit

		if [ -d /usr/local/lib/7dtd/server-fixes ]; then
			cp /usr/local/lib/7dtd/server-fixes/* $SDTD_BASE/engine/ -R
		fi

		chown $SDTD_USER.$SDTD_GROUP -R $SDTD_BASE/engine
	else
		echo "Engine is already at the newest build on the selected branch \"$BRANCHNAME\" (local: $LOCAL, remote: $REMOTE)."
		echo "Run with the --force parameter to update/validate the engine files anyway."
		echo "Run with --experimental, --stable or --branch to switch to a different branch."
	fi
}

sdtdCommandUpdateengineHelp() {
	echo "Usage: $(basename $0) updateengine [--check [--showinternal]] [--experimental | --stable] [--branch BRANCHNAME [--password BRANCHPASSWORD]] [--force]"
	echo
	echo "Check for a newer version of engine (aka game) files of 7dtd. If there is a newer"
	echo "version they will be updated by this command."
	echo
	echo "If neither --stable, nor --experimental nor --branch is specified the server will"
	echo "updated to the latest build on the currently installed Steam branch of the game."
	echo
	echo "If --stable is specified the server will be switched to the"
	echo "default public stable Steam branch of the game."
	echo
	echo "If --experimental is specified the server will be switched to the"
	echo "latest_experimental Steam branch of the game."
	echo
	echo "If --branch SOMEBRANCH is specified the server will be switched to the"
	echo "given Steam branch of the game. Additionally if password is required to acess"
	echo "the branch this can be specified with the --password argument."
	echo "NOTE that --password is also required if you previously switched to a branch that"
	echo "requires a password and want to update to the latest build on that branch now."
	echo
	echo "If --force is specified you are asked if you want to redownload the engine"
	echo "even if there is no new version detected."
	echo
	echo "If --check is specified it will only output the current local and remote build ids"
	echo "and if an update is available."
	echo "TFP internal branches are only shown if --showinternal is also given."
}

sdtdCommandUpdateengineDescription() {
	echo "Update the 7dtd engine files"
}

sdtdCommandUpdateengineExpects() {
	if [ "$2" = "--password" ]; then
		echo ""
	elif [ "$2" = "--branch" ]; then
		updateRemoteEngineInfo
		getBranchNames
	else
		echo "--check --showinternal --experimental --branch --password --stable --force"
	fi
}

# Get the latest remote (on Steam) engine version numbers etc
updateRemoteEngineInfo() {
	local DOCHECK=no
	if [ ! -e /tmp/7dtd-appinfo ]; then
		DOCHECK=yes
	else
		AGE=$((`date +%s` - `stat -L --format %Y /tmp/7dtd-appinfo`))
		if [ $AGE -gt 600 ]; then
			DOCHECK=yes
		fi
	fi
	if [ "$DOCHECK" = "yes" ]; then
		echo "Updating version information..."
		rm /root/Steam/appcache/appinfo.vdf
		cd $SDTD_BASE/steamcmd

		./steamcmd.sh +login anonymous +app_info_request 294420 +app_info_update +app_info_update 1 +app_info_print 294420 +quit | grep -A 1000 \"294420\" 2>/dev/null > /tmp/7dtd-appinfo
	
		local BUILDID=$(grep -A 1000 \"branches\" /tmp/7dtd-appinfo | grep -A 1000 \"public\" | grep -B 10 \} --max-count=1 | grep \"buildid\" | cut -d\" -f4)

		if [ $(isANumber "$BUILDID") -eq 0 ]; then
			rm -f /tmp/7dtd-appinfo
		fi
	fi
}

# Get the latest build id (on Steam)
# Params:
#   1. Branch name
# Returns:
#   "?" if data could not be retrieved
#   BuildId otherwise
getBuildId() {
	local BUILDID=$(grep -A 1000 \"branches\" /tmp/7dtd-appinfo | grep -A 1000 \"$1\" | grep -B 10 \} --max-count=1 | grep \"buildid\" | cut -d\" -f4)

	if [ $(isANumber "$BUILDID") -eq 0 ]; then
		echo "?"
	else
		echo $BUILDID
	fi
}

# Get the update time of the latest build (on Steam)
# Params:
#   1. Branch name
# Returns:
#   "?" if data could not be retrieved
#   Update timestamp otherwise
getBuildUpdateTime() {
	local TIMESTAMP=$(grep -A 1000 \"branches\" /tmp/7dtd-appinfo | grep -A 1000 \"$1\" | grep -B 10 \} --max-count=1 | grep \"timeupdated\" | cut -d\" -f4)
	
	if [ $(isANumber "$TIMESTAMP") -eq 0 ]; then
		echo "?"
	else
		date --date="@${TIMESTAMP}" "+%Y-%m-%d %H:%M:%S"
	fi
}

# Get a list of available branch names, blank separated
# Returns:
#   Blank separated list of branch names (can be empty if an error occured)
getBranchNames() {
	grep -A 1000 \"branches\" /tmp/7dtd-appinfo | grep -E '^[[:space:]]*"[^"]+"[[:space:]]*$' | tail --lines=+2 | cut -d\" -f2
}

