CC = gcc
CFLAGS = -Wall

default: all
all: netfit-mux netfit-demux

netfit-mux:
	$(CC) $(CFLAGS) src/netfit-mux.c -o bin/netfit-mux
netfit-demux:
	$(CC) $(CFLAGS) src/netfit-demux.c -o bin/netfit-demux

clean:
	-rm -f bin/netfit-mux
	-rm -f bin/netfit-demux
