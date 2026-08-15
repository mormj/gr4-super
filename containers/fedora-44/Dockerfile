# syntax=docker/dockerfile:1
#
# Fedora's fast-moving toolchain catches packaging and compiler regressions
# that do not appear in the Debian-family images.
FROM node:22-bookworm-slim AS node

FROM fedora:44 AS toolchain

ARG GR4_BUILD_TARGET=check

ENV CMAKE_BUILD_PARALLEL_LEVEL=4 \
    GR4_BUILD_TARGET=${GR4_BUILD_TARGET}

RUN dnf --assumeyes --setopt=install_weak_deps=False install \
        boost-devel \
        brotli-devel \
        ca-certificates \
        ccache \
        cli11-devel \
        cmake \
        cpp-httplib-devel \
        cppzmq-devel \
        curl-devel \
        gcc-c++ \
        git \
        gtest-devel \
        ncurses-devel \
        nlohmann-json-devel \
        ninja-build \
        openssl-devel \
        pkgconf-pkg-config \
        python3 \
        python3-devel \
        python3-numpy \
        rtaudio-devel \
        SoapySDR-devel \
        tbb-devel \
        zlib-ng-compat-devel \
    && dnf clean all

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
