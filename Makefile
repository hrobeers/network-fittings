CC = gcc
CFLAGS= -Wall -O3

default: all
all: mux demux

test: check
check: all
	./test/all.sh

mux:
	$(CC) $(CFLAGS) src/mux.c -o libexec/netfit/mux
demux:
	$(CC) $(CFLAGS) src/demux.c -o libexec/netfit/demux

clean:
	-rm -f libexec/netfit/mux
	-rm -f libexec/netfit/demux
