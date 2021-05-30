# Allocs fixes

This is a fork of [Allocs fixes](https://7dtd.illy.bz/wiki/Server%20fixes).

This repo is used to stage code changes before submitting to the main project.

All code and files in this repo are subject to the licenses of upstream projects.


## Building


Requires [websocket-sharp](https://github.com/sta/websocket-sharp). That dependency needs to be built first

Clone that repo, build with `xbuild websocket-sharp/websocket-sharp.csproj`. 
Resulting file is at `websocket-sharp/obj/Debug/websocket-sharp.dll`

Copy the dll to `binary-improvements/7dtd-binaries/websocket-sharp.dll`

Finally, build this project and optionally upload to a gameserver. See `uploadToDev.sh`