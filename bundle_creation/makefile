HOST=136.243.11.25
PORT=51010
SERVERPATH=/srv/www/illy.bz/http/fi/7dtd/

VERSIONFILE=../scripts/usr/local/lib/7dtd/VERSION
VERSION=$(shell cat ${VERSIONFILE} | grep "Version" | cut -d\  -f2)
ARCHIVENAME=management_scripts_v${VERSION}.tar.gz

build: CONTENTS ${ARCHIVENAME}
	@echo Bundle built successfully

all: build upload
	@echo Bundle built and uploaded

upload: ${ARCHIVENAME}
	@echo Uploading files...
	@scp -P ${PORT} ${ARCHIVENAME} ${VERSIONFILE} ${HOST}:${SERVERPATH}
	@ssh -p ${PORT} ${HOST} "cd ${SERVERPATH}; rm -f management_scripts.tar.gz; ln -s ${ARCHIVENAME} management_scripts.tar.gz"

${ARCHIVENAME}: CONTENTS
	@echo Creating archive...
	@tar -czf ${ARCHIVENAME} etc home usr

CONTENTS: SCRIPTS SSD

SCRIPTS:
	@rm etc home usr -Rf
	@echo Copying management scripts...
	@find ../scripts -name "*~" -exec rm {} \;
	@cp -r ../scripts/* .

SSD:
	@echo Copying start-stop-daemon source...
	@find ../tools -name "*~" -exec rm {} \;
	@cp -r ../tools/start-stop-daemon usr/local/lib/7dtd

SERVERFIXES:
	@echo Building server fixes...
	@make -C ../binary-improvements/bundle_creation/
	@echo Copying server fixes...
	@mkdir -p usr/local/lib/7dtd/server-fixes
	@cp ../binary-improvements/bundle_creation/Mods usr/local/lib/7dtd/server-fixes/ -R

clean:
	@echo Cleaning intermediate stuff...
	@rm -Rf usr home etc management_scripts_v*.tar.gz

