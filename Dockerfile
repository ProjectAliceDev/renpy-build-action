FROM ubuntu:18.04

RUN apt-get update
RUN apt-get install --yes bzip2 wget

COPY build.sh /build.sh

ENTRYPOINT ["/build.sh"]
