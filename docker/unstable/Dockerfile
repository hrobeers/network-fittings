# Build a compilation container in a first stage to minimize size
FROM debian:unstable-slim as builder

# Install build dependencies in separate layer for caching
RUN  set -x \
    && apt-get update \
    && apt-get install -y socat ca-certificates gcc make libc-dev bats git pv --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Build and run tests
RUN set -x \
    && git clone https://github.com/hrobeers/network-fittings.git \
    && cd network-fittings && make check \
    && ./install.sh /usr && cd .. \
    && rm -rf network-fittings

# Build the runtime container in second stage to minimize size
FROM debian:unstable-slim
MAINTAINER hrobeers <hrobeers@users.noreply.github.com>

# Install runtime dependencies
RUN  set -x \
    && apt-get update \
    && apt-get install -y socat --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Install netfit
COPY --from=builder /usr/bin/netfit-* /usr/bin/
COPY --from=builder /usr/libexec/netfit/ /usr/libexec/netfit/