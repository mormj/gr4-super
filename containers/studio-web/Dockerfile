# syntax=docker/dockerfile:1
#
# Browser-accessible GNU Radio 4 Studio.  The build uses the same Ubuntu 24.04
# GCC 14 base as integration CI, then keeps only the installed profile and the
# production web bundle in the runtime stage.
FROM node:22-bookworm-slim AS node

FROM ghcr.io/gnuradio/ci:ubuntu-24.04-4.0 AS build

ENV CMAKE_BUILD_PARALLEL_LEVEL=4

COPY --from=node /usr/local /usr/local

USER root
RUN install --directory --owner=ubuntu --group=users /workspace

WORKDIR /workspace
COPY --chown=ubuntu:users . /workspace
USER ubuntu

RUN cmake --preset full \
    && cmake --build --preset full \
    && cd src/gnuradio4-studio \
    && npm run build:web

FROM ghcr.io/gnuradio/ci:ubuntu-24.04-4.0 AS runtime

USER root
RUN apt-get update \
    && apt-get install --yes --no-install-recommends curl nginx-light \
    && rm -rf /var/lib/apt/lists/* \
    && install --directory --owner=ubuntu --group=users \
        /opt/gr4 \
        /usr/share/nginx/html \
        /tmp/nginx/client_body \
        /tmp/nginx/fastcgi \
        /tmp/nginx/proxy \
        /tmp/nginx/scgi \
        /tmp/nginx/uwsgi

COPY --from=build --chown=ubuntu:users /workspace/install/full /opt/gr4
COPY --from=build --chown=ubuntu:users /workspace/src/gnuradio4-studio/dist /usr/share/nginx/html
COPY containers/studio-web/nginx.conf /etc/nginx/nginx.conf
COPY containers/studio-web/entrypoint.sh /usr/local/bin/gr4-studio-web
RUN chmod 0755 /usr/local/bin/gr4-studio-web

ENV GR4_PREFIX=/opt/gr4 \
    PATH=/opt/gr4/bin:${PATH} \
    CMAKE_PREFIX_PATH=/opt/gr4 \
    LD_LIBRARY_PATH=/opt/gr4/lib:/opt/gr4/lib64 \
    PKG_CONFIG_PATH=/opt/gr4/lib/pkgconfig:/opt/gr4/lib64/pkgconfig:/opt/gr4/share/pkgconfig \
    PYTHONPATH=/opt/gr4/lib/python3/site-packages \
    GNURADIO4_PLUGIN_DIRECTORIES=/opt/gr4/lib/gnuradio-4/plugins:/opt/gr4/lib

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl --fail --silent --show-error http://127.0.0.1:8080/api/healthz || exit 1

USER ubuntu
WORKDIR /opt/gr4
ENTRYPOINT ["/usr/local/bin/gr4-studio-web"]
