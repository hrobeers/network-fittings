CC = gcc
CFLAGS= -Wall -O3

default: all
all: mux demux

test: check
check: all
	./test/all.sh

mux:
	$(CC) $(CFLAGS) src/mux.c -o bin/netfit-mux
demux:
	$(CC) $(CFLAGS) src/demux.c -o bin/netfit-demux

clean:
	-rm -f bin/netfit-mux
	-rm -f bin/netfit-demux
