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


genericHelp() {
	line() {
		printf "  %-*s %s\n" 15 "$1" "$2"
	}
	
	echo
	if [ ! -z $1 ]; then
		echo "Unknown command: $1"
	fi
	echo "Usage: $(basename $0) <command> [parameters]"
	echo
	echo "Commands are:"
	
	for C in $(listCommands); do
		if [ "$(type -t sdtdCommand$(camelcasePrep $C)Description)" = "function" ]; then
			line "${C}" "$(sdtdCommand$(camelcasePrep $C)Description)"
		else
			line "${C}" "TODO: Description"
		fi
	done
	
	echo
	echo "Use \"$(basename $0) help <command>\" to get further details on a specific command."
}


