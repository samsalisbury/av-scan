FROM debian:buster-slim

WORKDIR /root

COPY install ./
RUN ./install

COPY scan-dir ./

ENTRYPOINT ["/scan-dir"]
