#!/usr/bin/env bats

BD=${BATS_TEST_DIRNAME}/../bin

@test "mux: stdout pipe" {
    MSG=$(cat ${BATS_TEST_DIRNAME}/data/loremipsum)
    result=$(cat ${BATS_TEST_DIRNAME}/data/loremipsum | ${BD}/netfit-mux /dev/null | ${BD}/netfit-demux)
    [ "$result" == "$MSG" ]
}

@test "mux: stderr pipe" {
    MSG=$(cat ${BATS_TEST_DIRNAME}/data/loremipsum)
    err_fifo=$(mktemp /tmp/err.fifo.XXXXXXXXX --dry-run)
    mkfifo $err_fifo
    result=$(cat ${BATS_TEST_DIRNAME}/data/loremipsum > $err_fifo | ${BD}/netfit-mux $err_fifo | ${BD}/netfit-demux 2>&1 >/dev/null)
    rm $err_fifo
    [ "$result" == "$MSG" ]
}
