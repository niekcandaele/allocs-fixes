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


. /usr/local/lib/7dtd/common.sh
checkRootLoadConf

if [ -z $1 ]; then
	genericHelp
else
	CMD=$(camelcasePrep "$1")
	shift
	
	if [ "$CMD" = "Help" ]; then
		if [ -z $1 ]; then
			genericHelp
		else
			HELPCMD=$(camelcasePrep "$1")
			if [ "$(type -t sdtdCommand${HELPCMD}Help)" = "function" ]; then
				sdtdCommand${HELPCMD}Help
			else
				echo "Command \"$1\" does not exist!"
				exit 1
			fi
		fi
	else
		if [ "$(type -t sdtdCommand${CMD})" = "function" ]; then
			sdtdCommand${CMD} "$@"
		else
			echo "Command \"$CMD\" does not exist!"
			exit 1
		fi
	fi
fi

exit 0

