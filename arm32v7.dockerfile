
FROM alpine AS builder

# Download QEMU, see https://github.com/docker/hub-feedback/issues/1261
ENV QEMU_URL https://github.com/balena-io/qemu/releases/download/v3.0.0%2Bresin/qemu-3.0.0+resin-arm.tar.gz
RUN apk add curl && curl -L ${QEMU_URL} | tar zxvf - -C . --strip-components 1

FROM debian:buster

COPY --from=builder qemu-arm-static /usr/bin

RUN apt-get update && apt-get install wget \
 && wget https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install \
 && chmod +x install \
 && ./install -r -f 
 
 EXPOSE 80
