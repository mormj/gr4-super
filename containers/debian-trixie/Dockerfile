# syntax=docker/dockerfile:1
#
# Debian stable compatibility target.  This complements the rolling Sid canary
# with the package set users receive from the current supported Debian release.
FROM node:22-bookworm-slim AS node

FROM debian:trixie AS toolchain

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

# Studio requires Node 22.  Keep that runtime independent of the Debian stable
# package version so this image verifies the same application stack as Sid.
COPY --from=node /usr/local /usr/local

RUN useradd --create-home --uid 1000 --shell /bin/bash gr4 \
    && install --directory --owner=gr4 --group=gr4 /workspace

COPY containers/scripts/verify-preset.sh /usr/local/bin/gr4-verify
RUN chmod 0755 /usr/local/bin/gr4-verify

WORKDIR /workspace
USER gr4
ENTRYPOINT ["/usr/local/bin/gr4-verify"]

FROM toolchain AS verify

COPY --chown=gr4:gr4 . /workspace
RUN /usr/local/bin/gr4-verify full
