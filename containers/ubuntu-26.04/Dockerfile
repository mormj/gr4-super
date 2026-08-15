# syntax=docker/dockerfile:1
#
# Ubuntu's next LTS provides a forward-looking, but still release-based,
# counterpart to the rolling Debian Sid canary.
FROM node:22-bookworm-slim AS node

FROM ubuntu:26.04 AS toolchain

ARG GR4_BUILD_TARGET=check

ENV DEBIAN_FRONTEND=noninteractive \
    CMAKE_BUILD_PARALLEL_LEVEL=4 \
    GR4_BUILD_TARGET=${GR4_BUILD_TARGET}

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        build-essential \
        ca-certificates \
        ccache \
        cmake \
        git \
        libboost-dev \
        libbrotli-dev \
        libcli11-dev \
        libcpp-httplib-dev \
        cppzmq-dev \
        libcurl4-openssl-dev \
        libgtest-dev \
        libncurses-dev \
        nlohmann-json3-dev \
        libsoapysdr-dev \
        libssl-dev \
        libtbb-dev \
        librtaudio-dev \
        ninja-build \
        pkg-config \
        python3 \
        python3-dev \
        python3-numpy \
        zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

COPY --from=node /usr/local /usr/local

RUN install --directory --owner=ubuntu --group=ubuntu /workspace

COPY containers/scripts/verify-preset.sh /usr/local/bin/gr4-verify
RUN chmod 0755 /usr/local/bin/gr4-verify

WORKDIR /workspace
USER ubuntu
ENTRYPOINT ["/usr/local/bin/gr4-verify"]

FROM toolchain AS verify

COPY --chown=ubuntu:ubuntu . /workspace
RUN /usr/local/bin/gr4-verify full
