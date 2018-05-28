CC = gcc
CFLAGS= -Wall -O3

default: all
all: netfit-mux netfit-demux

test: check
check: all
	./test/all.sh

netfit-mux:
	$(CC) $(CFLAGS) src/netfit-mux.c -o bin/netfit-mux
netfit-demux:
	$(CC) $(CFLAGS) src/netfit-demux.c -o bin/netfit-demux

clean:
	-rm -f bin/netfit-mux
	-rm -f bin/netfit-demux
