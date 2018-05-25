network-fittings
================

A toolbox to connect your UNIX plumbing over the network.


Quickstart
----------
```bash
make check
```


Rationale
---------

All decent Unix tools can be assembled together like Lego bricks, using the well known stdin, stdout and stderr stream.
However, once your pipeline gets distributed over the network, things start to get complicated as duplex sockets have no place for stderr and passing commandline arguments can become cumbersome.

This toolbox aims at providing the required 'fittings' for transparently distributing your pipelines over the network.


### Stream multiplexing (netfit-mux & netfit-demux)

`netfit-mux` and `netfit-demux` allow to multiplex multiple binary streams (currently only 2) over a single stream.

Usage: [mux-tests.bats](./test/mux-tests.bats)


### Argument passing (netfit-passargs)

`netfit-passargs` allows streaming commandline arguments over stdin before streaming input.
