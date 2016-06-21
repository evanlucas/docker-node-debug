FROM buildpack-deps:jessie-curl

MAINTAINER Evan Lucas

RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    binfmt-support \
    gcc \
    git \
    g++ \
    libedit2 \
    libffi-dev \
    libjsoncpp0 \
    libpython2.7 \
    libtinfo-dev \
    locales \
    make \
    python \
    python-six \
    vim \
    xz-utils \
  && apt-get clean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV NODE_VERSION 6.2.2

# Clone and compile a debug build
RUN mkdir -p /tmp/build \
  && cd /tmp/build \
  && git clone git://github.com/nodejs/node \
  && cd node \
  && git fetch --tags \
  && git checkout v${NODE_VERSION} \
  && ./configure --debug --prefix=/usr/local \
  && make -j4 \
  && make install \
  && node -v \
  && node -pe process.config.target_defaults.default_configuration \
  && npm -v \
  && cd / \
  && rm -rf /tmp/build

COPY deb /packages
COPY install_lldb.sh /install_lldb.sh
RUN /install_lldb.sh

RUN update-alternatives \
      --install /usr/bin/lldb    lldb    /usr/bin/lldb-3.8 50 \
      --slave   /usr/bin/lldb-server lldb-server /usr/bin/lldb-server-3.8

RUN mkdir -p /tmp/build \
  && cd /tmp/build \
  && git clone git://github.com/indutny/llnode \
  && cd llnode \
  && git clone https://chromium.googlesource.com/external/gyp.git tools/gyp \
  && ./gyp_llnode -Dlldb_dir=/usr/lib/llvm-3.8/ \
  && make -C out/ \
  && make install-linux

RUN mkdir -p /opt/examples
WORKDIR /opt/examples
COPY example.js /opt/examples/

CMD ["bash"]
