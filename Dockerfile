FROM alpine:3.11
RUN apk add --no-cache \
  openssh-client \
  ca-certificates \
  ruby \
  bash

COPY src/ build/
RUN ln -s /build/bin/* /usr/local/bin/
