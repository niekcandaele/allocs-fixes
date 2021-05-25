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


# Tries to start the 7dtd instance.

sdtdCommandStart() {
	if [ "$1" = "!" ]; then
		echo "Starting all instances:"
		for I in $(getInstanceList); do
			printf "%-*s: " 10 "$I"
			sdtdCommandStart $I
		done
		echo "All done"
		return
	fi

	if [ $(isValidInstance $1) -eq 0 ]; then
		echo "No instance given or not a valid instance!"
		return
	fi

	if [ $(isRunning $1) -eq 0 ]; then
		# Kill monitor if it is still running
		if [ -f "$(getInstancePath $1)/monitor.pid" ]; then
			$PKILL -TERM -P $(cat $(getInstancePath $1)/monitor.pid)
			rm $(getInstancePath $1)/monitor.pid
		fi
		
		if [ ! -d "$(getInstancePath $1)/logs" ]; then
			mkdir "$(getInstancePath $1)/logs"
		fi
		chown $SDTD_USER.$SDTD_GROUP "$(getInstancePath $1)/logs"
		rm -f $(getInstancePath $1)/logs/output_log.txt
		
		for H in $(getHooksFor serverPreStart $1); do
			$H $1
		done

		LOGTIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
		LOG=$(getInstancePath $1)/logs/${LOGTIMESTAMP}_output_log.txt
		SSD_PID="--pidfile $(getInstancePath $1)/7dtd.pid --make-pidfile"
		SSD_DAEMON="--background --no-close"
		SSD_USER="--chuid $SDTD_USER:$SDTD_GROUP --user $SDTD_USER"
		OPTS="-logfile $LOG -nographics -configfile=$(getInstancePath $1)/config.xml"
		
		if [ "$(uname -m)" = "x86_64" ]; then
			SERVER_EXE="7DaysToDieServer.x86_64"
		else
			SERVER_EXE="7DaysToDieServer.x86"
		fi

		
		LC_ALL=C LD_LIBRARY_PATH=$SDTD_BASE/engine $SSD --start $SSD_PID $SSD_DAEMON $SSD_USER --chdir $SDTD_BASE/engine --exec $SDTD_BASE/engine/$SERVER_EXE -- $OPTS > $(getInstancePath $1)/logs/stdout.log 2>&1
		sleep 1

		for H in $(getHooksFor serverPostStart $1); do
			$H $1
		done

		if [ $(isRunning $1) -eq 1 ]; then
			SSD_MONITOR_PID="--pidfile $(getInstancePath $1)/monitor.pid --make-pidfile"
			SSD_MONITOR_DAEMON="--background"
			$SSD --start $SSD_MONITOR_PID $SSD_MONITOR_DAEMON --exec "/usr/local/lib/7dtd/monitor-log.sh" -- "$1" "$LOGTIMESTAMP"
			echo "Done!"
		else
			echo "Failed!"
			rm -f $(getInstancePath $1)/7dtd.pid
		fi
	else
		echo "Instance $1 is already running"
	fi
}

sdtdCommandStartHelp() {
	echo "Usage: $(basename $0) start <instance>"
	echo
	echo "Starts the given instance."
	echo "If <instance> is \"!\" all defined instances are started."
}

sdtdCommandStartDescription() {
	echo "Start the given instance"
}

sdtdCommandStartExpects() {
	case $1 in
		2)
			echo "! $(getInstanceList)"
			;;
	esac
}

