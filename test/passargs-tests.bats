#!/usr/bin/env bats

BD=${BATS_TEST_DIRNAME}/../bin
loremipsum=${BATS_TEST_DIRNAME}/data/loremipsum

@test "passargs: no args" {
    result=$(head -n 3 -q $loremipsum        `# take the first 3 lines of loremipsum` \
                 | cat <(printf "\n") -      `# prepend a newline char to signal no arguments are passed` \
                 | ${BD}/netfit-passargs cat `# run cat through passargs` \
                 | wc -l)                    `# count the lines for verification`

    # Verify
    [ $result == 3 ]
}

@test "passargs: single arg" {
    result=$(head -n 3 -q $loremipsum        `# take the first 3 lines of loremipsum` \
                 | cat <(echo "-l") -        `# pass a single argument before newline char (implicitly added by echo)` \
                 | ${BD}/netfit-passargs wc) `# run wc with -l passed on stdin through passargs`

    # Verify
    [ $result == 3 ]
}

@test "passargs: multi arg" {
    result=$(cat $loremipsum                  `# read loremipsum` \
                 | cat <(echo "-n 3 -v") -    `# pass multiple arguments before newline char (implicitly added by echo)` \
                 | ${BD}/netfit-passargs head `# run wc with -l passed on stdin through passargs` \
                 | wc -l)                     `# count the lines for verification`

    # Verify
    [ $result == 4 ]
}
