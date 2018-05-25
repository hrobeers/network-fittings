#!/usr/bin/env bats

BD=${BATS_TEST_DIRNAME}/../bin
loremipsum=${BATS_TEST_DIRNAME}/data/loremipsum

@test "mux: stdout pipe" {
    # Pipe loremipsum over std channel
    result=$(cat $loremipsum \
                 | ${BD}/netfit-mux /dev/null      `# multiplex stdin and /dev/null over stdout` \
                 | ${BD}/netfit-demux 2>/dev/null) `# demultiplex and write err stream to /dev/null`

    # Verify
    [ "$result" == "$(cat $loremipsum)" ]
}

@test "mux: stderr pipe" {
    # Create err fifo
    err_fifo=$(mktemp /tmp/err.fifo.XXXXXXXXX --dry-run)
    mkfifo $err_fifo

    # Pipe loremipsum over err channel
    result=$(cat $loremipsum > $err_fifo               `# write loremipsum to err_fifo` \
                 | ${BD}/netfit-mux $err_fifo          `# multiplex err_fifo on err channel over stdout` \
                 | ${BD}/netfit-demux 2>&1 >/dev/null) `# demultiplex, write err stream to result and discard std stream`

    # Cleanup
    rm $err_fifo

    # Verify
    [ "$result" == "$(cat $loremipsum)" ]
}

@test "mux: mixed pipe" {
    # Create err fifo and out file
    err_fifo=$(mktemp /tmp/err.fifo.XXXXXXXXX --dry-run)
    mkfifo $err_fifo
    err_out=$(mktemp /tmp/err.out.XXXXXXXXX)

    # Pipe loremipsum over err and std channel (base64 encoded over std channel)
    result=$(cat $loremipsum \
                 | tee $err_fifo                  `# duplicate to err_fifo` \
                 | base64                         `# base64 encode std channel to make streams different` \
                 | ${BD}/netfit-mux $err_fifo     `# multiplex over stdout` \
                 | ${BD}/netfit-demux 2>$err_out) `# demultiplex and write err stream to err_out`

    # Read err_out
    result_err=$(cat $err_out)

    # Cleanup
    rm $err_fifo $err_out

    # Verify
    [ "$result" == "$(cat $loremipsum | base64)" ]
    [ "$result_err" == "$(cat $loremipsum)" ]
}

@test "mux: binary pipe" {
    # Create err fifo and out file
    err_fifo=$(mktemp /tmp/err.fifo.XXXXXXXXX --dry-run)
    mkfifo $err_fifo
    err_out=$(mktemp /tmp/err.out.XXXXXXXXX)

    # Pipe loremipsum over err and std channel (gzip compressed over std channel)
    result=$(cat $loremipsum \
                 | tee $err_fifo                 `# duplicate to err_fifo` \
                 | gzip                          `# gzip compress std channel` \
                 | ${BD}/netfit-mux $err_fifo    `# multiplex over stdout` \
                 | ${BD}/netfit-demux 2>$err_out `# demultiplex and write err stream to err_out` \
                 | gunzip)                       `# decompress std channel`

    # Read err_out
    result_err=$(cat $err_out)

    # Cleanup
    rm $err_fifo $err_out

    # Verify
    [ "$result" == "$(cat $loremipsum)" ]
    [ "$result_err" == "$(cat $loremipsum)" ]
}

@test "mux: choked pipe" {
    bytes="5K"      # truncate loremipsum to bytes to reduce test time
    choke_time=0.01 # time to sleep per multiplexed line

    # Create err fifo and out file
    err_fifo=$(mktemp /tmp/err.fifo.XXXXXXXXX --dry-run)
    mkfifo $err_fifo
    err_out=$(mktemp /tmp/err.out.XXXXXXXXX)

    result=$(cat $loremipsum \
                 | head -c $bytes                 `# truncate to reduce test time` \
                 | tee $err_fifo                  `# duplicate to err_fifo` \
                 | base64                         `# base64 encode std channel to make streams different` \
                 | ${BD}/netfit-mux $err_fifo     `# multiplex over stdout` \
                 | base64 -w 500                  `# base64 encode (wrapped) to make the choke work on line basis` \
                 | while read -r line; do echo "$line"; sleep $choke_time; done \
                 | base64 -d                      `# base64 decode after choking` \
                 | ${BD}/netfit-demux 2>$err_out) `# demultiplex and write err stream to err_out`

    # Read err_out
    result_err=$(cat $err_out)

    # Cleanup
    rm $err_fifo $err_out

    # Verify
    [ "$result" == "$(cat $loremipsum | head -c $bytes | base64)" ]
    [ "$result_err" == "$(cat $loremipsum | head -c $bytes)" ]
}
