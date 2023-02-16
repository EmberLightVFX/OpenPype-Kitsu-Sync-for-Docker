from ubuntu:focal AS builder
ARG OPENPYPE_PYTHON_VERSION=3.9.12

LABEL maintainer="Jacob Danell <jacob@emberlight.se>"
LABEL description="Docker Image to run OpenPypes Kitsu Sync under Ubuntu 20.04"

USER root

ARG DEBIAN_FRONTEND=noninteractive

# update base
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        bash \
        git \
        curl \
        wget \
        jq \
        unzip \
        build-essential \
        libssl-dev \
        libreadline-dev \
        tk-dev \
        libffi-dev \
        libsqlite3-dev \
    && rm -rf /var/lib/apt/lists/*

SHELL ["/bin/bash", "-c"]

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

RUN mkdir /opt/openpype

# download and install pyenv
RUN curl https://pyenv.run | bash \
    && echo 'export PATH="$HOME/.pyenv/bin:$PATH"'>> $HOME/init_pyenv.sh \
    && echo 'eval "$(pyenv init -)"' >> $HOME/init_pyenv.sh \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> $HOME/init_pyenv.sh \
    && echo 'eval "$(pyenv init --path)"' >> $HOME/init_pyenv.sh

# install python with pyenv
RUN source $HOME/init_pyenv.sh \
    && pyenv install ${OPENPYPE_PYTHON_VERSION}

COPY run_sync.sh /opt/run_sync.sh
VOLUME /opt/openpype

CMD /opt/run_sync.sh