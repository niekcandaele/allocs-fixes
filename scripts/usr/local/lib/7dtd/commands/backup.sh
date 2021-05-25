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


# Backups game data files.

sdtdCommandBackup() {
	local DT=`date "+%Y-%m-%d_%H-%M"`
	local NewBackup=$SDTD_BACKUP_ROOT/$DT
	
	if [ ! -d "$SDTD_BASE/instances" ]; then
		return
	fi

	if [ "$SDTD_BACKUP_SAVEWORLD" == "true" ]; then
		for I in $(getInstanceList); do
			if [ $(isRunning $I) -eq 1 ]; then
				telnetCommand $I saveworld 2 > /dev/null
			fi
		done
	fi

	# Check for backup folder existence
	if [ -e $SDTD_BACKUP_ROOT ]; then
		# Exists, copy(link) latest backup
		unset -v LatestBackup
		local fileI
		for fileI in $(find "$SDTD_BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d); do
			if [ "$fileI" -nt "$LatestBackup" ]; then
				LatestBackup=$fileI
			fi
		done
		if [ -d "$LatestBackup" ]; then
			cp -al "$LatestBackup" "$NewBackup"
		fi
	fi

	if [ ! -d $SDTD_BACKUP_ROOT ]; then
		# Create new backup dir
		mkdir $SDTD_BACKUP_ROOT
	fi

	for H in $(getHooksFor serverPreBackup); do
		$H
	done

	$RSYNC -a --delete --numeric-ids --delete-excluded $SDTD_BASE/instances/./ $NewBackup
	touch $NewBackup
	
	## Compress if enabled
	case ${SDTD_BACKUP_COMPRESS:-none} in
		all)
			local dfname=$(basename $NewBackup)
			cd $SDTD_BACKUP_ROOT
			tar -czf $dfname.tar.gz $dfname
			touch -r $dfname $dfname.tar.gz
			rm -Rf $dfname
			;;
		old)
			if [ -d $LatestBackup ]; then
				local dfname=$(basename $LatestBackup)
				cd $SDTD_BACKUP_ROOT
				tar -czf $dfname.tar.gz $dfname
				touch -r $dfname $dfname.tar.gz
				rm -Rf $dfname
			fi
			;;
		none)
			;;
	esac
	
	cd $SDTD_BACKUP_ROOT
	
	## Purge old/too many backups
	local keepMin=${SDTD_BACKUP_MIN_BACKUPS_KEEP:-0}
	if [ $(isANumber $SDTD_BACKUP_MAX_BACKUPS) -eq 1 ]; then
		local removeBut=$SDTD_BACKUP_MAX_BACKUPS
		if [ $SDTD_BACKUP_MAX_BACKUPS -lt $keepMin ]; then
			removeBut=$keepMin
		fi
		local num=0
		local F
		for F in $(ls -t1 $SDTD_BACKUP_ROOT); do
			(( num++ ))
			if [ $num -gt $removeBut ]; then
				rm -Rf $F
			fi
		done
	fi
	if [ $(isANumber $SDTD_BACKUP_MAX_AGE) -eq 1 ]; then
		local FINDBASE="find $SDTD_BACKUP_ROOT -mindepth 1 -maxdepth 1"
		# Only continue if there are more than MIN_BACKUPS_KEEP backups at all
		if [ $($FINDBASE | wc -l) -gt $keepMin ]; then
			local minutes=$(( $SDTD_BACKUP_MAX_AGE*60 ))
			while [ $($FINDBASE -mmin -$minutes | wc -l) -lt $keepMin ]; do
				minutes=$(( minutes+60 ))
			done
			$FINDBASE -mmin +$minutes -exec rm -Rf {} \;
		fi
	fi
	if [ $(isANumber $SDTD_BACKUP_MAX_STORAGE) -eq 1 ]; then
		local maxKBytes=$(( $SDTD_BACKUP_MAX_STORAGE*1024 ))
		local curNumFiles=$(ls -t1 $SDTD_BACKUP_ROOT | wc -l)
		while [ $(du -sk $SDTD_BACKUP_ROOT | tr '[:blank:]' ' ' | cut -d\  -f1) -gt $maxKBytes -a $curNumFiles -gt $keepMin ]; do
			local toDel=$(ls -tr1 | head -n 1)
			rm -Rf $toDel
			(( curNumFiles-- ))
		done
	fi

	for H in $(getHooksFor backup); do
		if [ "$SDTD_BACKUP_COMPRESS" = "all" ]; then
			$H $NewBackup.tar.gz
		else
			$H $NewBackup
		fi
	done
	for H in $(getHooksFor serverPostBackup); do
		if [ "$SDTD_BACKUP_COMPRESS" = "all" ]; then
			$H $NewBackup.tar.gz
		else
			$H $NewBackup
		fi
	done
}

sdtdCommandBackupHelp() {
	echo "Usage: $(basename $0) backup"
	echo
	echo "Backups all data files (instance configurations, save data, logs)."
}

sdtdCommandBackupDescription() {
	echo "Backup game data files"
}
