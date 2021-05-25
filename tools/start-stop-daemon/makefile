start-stop-daemon: start-stop-daemon.c
	gcc -Wall -Wextra -Wno-return-type -o $@ $<

install: start-stop-daemon
	chown root.root start-stop-daemon
	chmod 0755 start-stop-daemon

clean:
	rm start-stop-daemon
