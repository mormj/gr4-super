# syntax=docker/dockerfile:1
#
# Known-good control image.  It extends the Ubuntu 24.04 GCC 14 image used by
# the existing integration workflow, then adds only the Node 22 runtime and
# the reusable platform-verification entrypoint.
FROM node:22-bookworm-slim AS node

FROM ghcr.io/gnuradio/ci:ubuntu-24.04-4.0 AS toolchain

ARG GR4_BUILD_TARGET=check

ENV CMAKE_BUILD_PARALLEL_LEVEL=4 \
    GR4_BUILD_TARGET=${GR4_BUILD_TARGET}

COPY --from=node /usr/local /usr/local

USER root
RUN install --directory --owner=ubuntu --group=users /workspace

COPY containers/scripts/verify-preset.sh /usr/local/bin/gr4-verify
RUN chmod 0755 /usr/local/bin/gr4-verify

WORKDIR /workspace
USER ubuntu
ENTRYPOINT ["/usr/local/bin/gr4-verify"]

FROM toolchain AS verify

COPY --chown=ubuntu:users . /workspace
RUN /usr/local/bin/gr4-verify full
