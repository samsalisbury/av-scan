FROM debian:buster-slim

WORKDIR /root

COPY install ./
RUN ./install

COPY scan-dir* /

ENTRYPOINT ["/bin/bash"]

CMD /scan-dir /files-to-scan
