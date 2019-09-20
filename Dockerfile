FROM ubuntu:18.04
COPY build.sh /build.sh
ENTRYPOINT ["/build.sh"]
