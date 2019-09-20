FROM golang:latest
COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
