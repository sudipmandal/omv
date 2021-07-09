
FROM alpine AS builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-aarch64.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM debian:buster

# Add QEMU
COPY --from=builder qemu-aarch64-static /usr/bin

COPY openmediavault.list /etc/apt/sources.list.d/

ENV DEBIAN_FRONTEND noninteractive

ENV LANG=C.UTF-8
ENV APT_LISTCHANGES_FRONTEND=none

RUN apt-get update && apt-get install --no-install-recommends -yq wget \
 && wget -O "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.asc" https://packages.openmediavault.org/public/archive.key \
 && apt-key add "/etc/apt/trusted.gpg.d/openmediavault-archive-keyring.asc" \
 && apt-get --yes --auto-remove --show-upgraded \
    --allow-downgrades --allow-change-held-packages \
    --no-install-recommends \
    --option Dpkg::Options::="--force-confdef" \
    --option DPkg::Options::="--force-confold" \
    install openmediavault-keyring openmediavault

#RUN omv-confdbadm populate

# We need to make sure rrdcached uses /data for it's data
COPY defaults/rrdcached /etc/default

# Add our startup script last because we don't want changes
# to it to require a full container rebuild
COPY omv-startup /usr/sbin/omv-startup
RUN chmod +x /usr/sbin/omv-startup

EXPOSE 80 443

VOLUME /data

ENTRYPOINT /usr/sbin/omv-startup
