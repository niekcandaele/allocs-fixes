#!/bin/sh

# This script works for my (Catalysm) personal workflow.
# It will likely not work out of the box for you but it's still included here :)

# Stop the dev server
ssh 7d2d.csmm.app ./sdtdserver stop

# Compile it!
xbuild binary-improvements/server-fixes.sln

# Transfer new built files
ssh 7d2d.csmm.app 'rm -rf /home/catalysm/serverfiles/Mods/Allocs*'
scp -r binary-improvements/bin/Mods/* 7d2d.csmm.app:/home/catalysm/serverfiles/Mods

ssh 7d2d.csmm.app mkdir /home/catalysm/serverfiles/Mods/Allocs_WebAndMapRendering/webserver

# Start the dev server again
ssh 7d2d.csmm.app ./sdtdserver start