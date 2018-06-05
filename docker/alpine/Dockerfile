# Build a compilation container in a first stage to minimize size
FROM alpine as builder

# Install build dependencies in separate layer for caching
RUN apk --update add socat gcc make libc-dev bats git pv \
    && rm -rf /var/cache/apk/*

# Build and run tests
RUN git clone https://github.com/hrobeers/network-fittings.git \
    && cd network-fittings \
    && cp docker/alpine/mktemp-fifo.sh libexec/netfit/ \
    && make check \
    && ./install.sh /usr && cd .. \
    && rm -rf network-fittings

# Build the runtime container in second stage to minimize size
FROM alpine
MAINTAINER hrobeers <hrobeers@users.noreply.github.com>

# Install runtime dependencies
RUN apk --update add bash coreutils socat \
    && rm -rf /var/cache/apk/*

# Install netfit
COPY --from=builder /usr/bin/netfit-* /usr/bin/
COPY --from=builder /usr/libexec/netfit/ /usr/libexec/netfit/
