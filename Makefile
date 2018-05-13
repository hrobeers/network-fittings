CC = gcc
CFLAGS = -Wall

default: all
all: pipe_mux pipe_demux

pipe_mux:
	$(CC) $(CFLAGS) src/pipe_mux.c -o bin/pipe_mux
pipe_demux:
	$(CC) $(CFLAGS) src/pipe_demux.c -o bin/pipe_demux

clean:
	-rm -f bin/pipe_mux
	-rm -f bin/pipe_demux
