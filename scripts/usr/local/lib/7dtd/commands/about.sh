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


sdtdCommandAbout() {
	echo "7 Days to Die - Linux Server Management Scripts"
	echo "Website: https://7dtd.illy.bz"
	echo
	cat /usr/local/lib/7dtd/VERSION
}

sdtdCommandAboutHelp() {
	sdtdCommandAbout
}

sdtdCommandAboutDescription() {
	echo "Version and short info about these scripts"
}

