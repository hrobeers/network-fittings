#!/usr/bin/env bats

BD=${BATS_TEST_DIRNAME}/../bin
loremipsum=${BATS_TEST_DIRNAME}/data/loremipsum

@test "mux: stdout pipe" {
    result=$(cat $loremipsum | ${BD}/netfit-mux /dev/null | ${BD}/netfit-demux)
    [ "$result" == "$(cat $loremipsum)" ]
}

@test "mux: stderr pipe" {
    err_fifo=$(mktemp /tmp/err.fifo.XXXXXXXXX --dry-run)
    mkfifo $err_fifo
    result=$(cat $loremipsum > $err_fifo | ${BD}/netfit-mux $err_fifo | ${BD}/netfit-demux 2>&1 >/dev/null)
    rm $err_fifo
    [ "$result" == "$(cat $loremipsum)" ]
}

@test "mux: mixed pipe" {
    err_fifo=$(mktemp /tmp/err.fifo.XXXXXXXXX --dry-run)
    mkfifo $err_fifo
    err_out=$(mktemp /tmp/err.out.XXXXXXXXX)

    result=$(cat $loremipsum | tee $err_fifo | base64 | ${BD}/netfit-mux $err_fifo | ${BD}/netfit-demux 2>$err_out)
    result_err=$(cat $err_out)
    rm $err_fifo $err_out
    [ "$result" == "$(cat $loremipsum | base64)" ]
    [ "$result_err" == "$(cat $loremipsum)" ]
}
