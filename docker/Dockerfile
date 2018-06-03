FROM alpine
MAINTAINER hrobeers <hrobeers@users.noreply.github.com>

# Runtime deps
RUN apk --update add bash coreutils socat && rm -rf /var/cache/apk/*

# network-fittings build, install and cleanup
RUN apk --update add --virtual build-dependencies gcc make libc-dev bats git pv && \
    git clone https://github.com/hrobeers/network-fittings.git && \
    cd network-fittings && make check && \
    ./install.sh /usr && cd .. && \
    apk del build-dependencies && \
    rm -rf network-fittings && \
    rm -rf /var/cache/apk/*