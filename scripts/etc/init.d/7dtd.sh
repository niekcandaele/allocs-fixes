#!/bin/sh

### BEGIN INIT INFO
# Provides:          7dtd-server
# Required-Start:    $remote_fs
# Required-Stop:     $remote_fs
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: 7 Days to Die server
# Description:       Starts a 7 Days to Die server
### END INIT INFO

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


case "$1" in
    start)
    	/usr/local/bin/7dtd.sh start "!"
    ;;
    stop)
    	/usr/local/bin/7dtd.sh kill "!"
    ;;
    status)
    	/usr/local/bin/7dtd.sh instances
    ;;
    *)
        echo "Usage: ${0} {start|stop|status}"
        exit 2
esac
exit 0
