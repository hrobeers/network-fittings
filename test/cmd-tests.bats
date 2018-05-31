#!/usr/bin/env bats

BD=${BATS_TEST_DIRNAME}/../bin
loremipsum=${BATS_TEST_DIRNAME}/data/loremipsum

# pid file
pids="/tmp/netfit-test.pids"
[ -f "$pids" ] || touch $pids

cleanup() {
    # kill all background processes
    while read pid
    do
	      kill "$pid"
    done < $pids
    # truncate the pid file to remove killed pids
    truncate -s0 $pids
}

# Make sure a full cleanup is done on exit
trap "set +e; cleanup; rm $pids" EXIT

@test "cmd: no args" {
    # start a cat server and save pid
    ${BD}/netfit-cmd-server cat 3>&- &
    echo "$!" >> $pids

    # Use cmd-client as a cat alias
    result=$(cat $loremipsum                `# read loremipsum` \
                 | ${BD}/netfit-cmd-client) `# send to cmd-server`

    cleanup
    # Verify
    [ "$result" == "$(cat $loremipsum)" ]
}

@test "cmd: single arg" {
    # start a wc server and save pid
    ${BD}/netfit-cmd-server wc 3>&- &
    echo "$!" >> $pids

    # Use cmd-client as a wc alias
    ${BD}/netfit-cmd-server cat 2>/dev/null 3>&- &
    result=$(head -n 50 -q $loremipsum         `# take the first 50 lines of loremipsum` \
                 | ${BD}/netfit-cmd-client -l) `# send to wc server with -l argument`

    cleanup
    # Verify
    [ $result == 50 ]
}

@test "cmd: multi arg" {
    # start a head -v server and save pid
    ${BD}/netfit-cmd-server head -v 3>&- &
    echo "$!" >> $pids

    # Use cmd-client as a head -v alias
    result=$(cat $loremipsum                    `# read loremipsum` \
                 | ${BD}/netfit-cmd-client -n 3 `# send to head -v server with -n 3 argument` \
                 | wc -l)                       `# count the lines for verification`

    cleanup
    # Verify
    [ $result == 4 ]
}

@test "cmd: cmd with PORT and HOST" {
    # head client alias that requires line count as first argument
    $(alias head_client="PORT=1234 ${BD}/netfit-cmd-client -n")

    # start a "head -q -n" server requires line count as first argument on port 4321
    PORT=4321 ${BD}/netfit-cmd-server head -q -n 3>&- &
    echo "$!" >> $pids

    # Ensure connecting on the implicit port (9833) fails
    ! cat $loremipsum | ${BD}/netfit-cmd-client 9
    # Ensure connecting on an incorrect port fails
    ! cat $loremipsum | PORT=1111 ${BD}/netfit-cmd-client 9
    # Ensure that connecting to an invalid host fails
    ! cat $loremipsum | HOST="invalidhost" ${BD}/netfit-cmd-client 9

    # Use cmd-client as a head -v alias
    result=$(cat $loremipsum                                          `# read loremipsum` \
                 | PORT=4321 HOST=127.0.0.1 ${BD}/netfit-cmd-client 9 `# specify host and port` \
                 | wc -l)                                             `# count the lines for verification`

    cleanup
    # Verify
    [ $result == 9 ]
}
