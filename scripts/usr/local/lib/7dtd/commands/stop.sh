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


# Tries to stop the 7dtd instance given as first parameter.
# Returns:
#  0 : Done
#  1 : Was not running
#  2 : No instance name given
#  3 : No such instance

sdtdCommandKill() {
	if [ "$1" = "!" ]; then
		echo "Stopping all instances:"
		for I in $(getInstanceList); do
			printf "%s:\n" "$I"
			sdtdCommandKill $I
			echo
		done
		echo "All done"
		return
	fi

	if [ $(isValidInstance $1) -eq 0 ]; then
		echo "No instance given or not a valid instance!"
		return
	fi

	res=$(isRunning $1)
	if [ $res -eq 1 ]; then
		for H in $(getHooksFor serverPreStop $1); do
			$H $1
		done

		echo "Trying to gracefully shutdown..."
		tmp=$(telnetCommand $1 shutdown "0.5")
		echo "Waiting for server to shut down..."
	
		waittime=0
		maxwait=${STOP_WAIT:-5}
		until [ $(isRunning $1) -eq 0 ] || [ $waittime -eq $maxwait ]; do
			(( waittime++ ))
			sleep 1
			echo $waittime/$maxwait
		done
	
		if [ $(isRunning $1) -eq 1 ]; then
			echo "Failed, force closing server..."
			$SSD --stop --signal KILL --pidfile $(getInstancePath $1)/7dtd.pid
		fi

		$PKILL -TERM -P $(cat $(getInstancePath $1)/monitor.pid)
		rm $(getInstancePath $1)/monitor.pid

		rm $(getInstancePath $1)/7dtd.pid

		for H in $(getHooksFor serverPostStop $1); do
			$H $1
		done

		echo "Done"	
	else
		echo "Instance $1 is NOT running"
	fi
}

sdtdCommandKillHelp() {
	echo "Usage: $(basename $0) kill <instance>"
	echo
	echo "Stops the given instance."
	echo "If <instance> is \"!\" all defined instances are stopped."
}

sdtdCommandKillDescription() {
	echo "Stop the given instance"
}

sdtdCommandKillExpects() {
	case $1 in
		2)
			echo "! $(getInstanceList)"
			;;
	esac
}

