#!/usr/bin/env bats

BD=${BATS_TEST_DIRNAME}/../bin
loremipsum=${BATS_TEST_DIRNAME}/data/loremipsum
lorem_expected=/tmp/lorem.expected
trap "rm $lorem_expected" EXIT

@test "mux: stdout pipe" {
    # Pipe loremipsum over std channel
    result=$(cat $loremipsum \
                 | ${BD}/netfit-mux /dev/null      `# multiplex stdin and /dev/null over stdout` \
                 | tee $lorem_expected             `# $lorem_expected will be tested against in later tests`\
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

@test "mux: small buffer mux" {
    result=$(cat $loremipsum \
                 | ${BD}/netfit-mux /dev/null     `# multiplex over stdout` \
                 | pv -q -B 8                     `# stream to process with 8 byte buffer` \
                 | sha256sum)

    # Verify
    [ "$result" == "$(cat $lorem_expected | sha256sum)" ]
}

@test "mux: small buffer demux" {
    # Test small buffer on the input
    in_result=$(cat $lorem_expected \
                    | pv -q -B 8                     `# stream from process with 8 byte buffer` \
                    | ${BD}/netfit-demux 2>/dev/null)`# demultiplex and write err stream to err_out`

    # Verify
    [ "$in_result" == "$(cat $loremipsum)" ]


    # Test small buffer on the output
    out_result=$(cat $lorem_expected \
                     | ${BD}/netfit-demux 2>/dev/null `# demultiplex and write err stream to err_out` \
                     | pv -q -B 8)                    `# stream from process with 8 byte buffer`

    # Verify
    [ "$out_result" == "$(cat $loremipsum)" ]
}

@test "mux: small buffer pipe" {
    result=$(cat $loremipsum \
                 | pv -q -B 8                     `# stream from process with 8 byte buffer` \
                 | ${BD}/netfit-mux /dev/null     `# multiplex over stdout` \
                 | pv -q -B 3                     `# stream through process with 3 byte buffer` \
                 | ${BD}/netfit-demux 2>/dev/null)`# demultiplex and write err stream to err_out`

    # Verify
    [ "$result" == "$(cat $loremipsum)" ]
}

@test "mux: choked pipe" {
    bytes="1K"        # truncate loremipsum to bytes to reduce test time
    choke_in="2000"   # choke mux input to bytes per second
    choke_pipe="1500" # choke multiplexed pipeline to bytes per second
    choke_out="1000"  # choke demux stdout to bytes per second

    result=$(cat $loremipsum \
                 | head -c $bytes                 `# truncate to reduce test time` \
                 | pv -q -L $choke_in             `# choke mux input` \
                 | ${BD}/netfit-mux /dev/null     `# multiplex over stdout` \
                 | pv -q -L $choke_pipe           `# choke multiplexed pipline (more than expected mux output rate)` \
                 | ${BD}/netfit-demux 2>/dev/null `# demultiplex and write err stream to err_out` \
                 | pv -q -L $choke_out)

    # Verify
    [ "$result" == "$(cat $loremipsum | head -c $bytes)" ]
}
