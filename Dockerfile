# syntax=docker/dockerfile:1.4

# Minimal Ubuntu Dockerfile for Lumerical installation
FROM ubuntu:22.04

# Non-interactive
ENV DEBIAN_FRONTEND=noninteractive

# Copy scripts into cointainer
COPY /scripts/ /scripts/

RUN --mount=type=bind,source=/lumerical/,target=/lumerical/ \ 
    apt-get update && apt-get install -y gosu \
    && /scripts/lumerical.sh install \
    && /scripts/openconnect.sh install \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/*

WORKDIR /home

ENTRYPOINT ["/scripts/docker-entrypoint.sh"]
