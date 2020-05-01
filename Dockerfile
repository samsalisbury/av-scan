FROM debian:buster-slim

WORKDIR /root

COPY install ./
RUN ./install

COPY scan-dir* /

ENTRYPOINT ["/bin/bash", "-c"]

CMD ["/bin/echo 'usage: </scan-dir | /scan-dir-clamav | /scan-dir-maldet> <DIR>'"]
