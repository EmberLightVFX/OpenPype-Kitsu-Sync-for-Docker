from ubuntu:focal

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        unzip \
        wget \
        curl \
        jq \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN mkdir /opt/openpype
WORKDIR /opt/openpype

COPY run_sync.sh /opt/run_sync.sh

VOLUME /opt/openpype
CMD /opt/run_sync.sh