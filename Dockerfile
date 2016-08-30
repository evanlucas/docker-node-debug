FROM buildpack-deps:jessie-curl

MAINTAINER Evan Lucas

RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - \
  && echo "deb http://apt.llvm.org/jessie/ llvm-toolchain-jessie-3.7 main" | tee -a /etc/apt/sources.list \
  && echo "deb-src http://apt.llvm.org/jessie/ llvm-toolchain-jessie-3.7 main" | tee -a /etc/apt/sources.list \
  && apt-get update \
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
    lldb-3.7 \
    lldb-3.7-dev \
    locales \
    make \
    python \
    python-six \
    vim \
    xz-utils \
  && apt-get clean \
  && apt-get autoremove -y \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
  && for f in $(find /usr/bin -name '*-3.7'); do ln -s $f `echo $f | sed s/-3.7//`; done

ENV NODE_VERSION 6.5.0

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

RUN mkdir -p /tmp/build \
    && cd /tmp/build \
    && git clone git://github.com/indutny/llnode \
    && cd llnode \
    && git clone https://chromium.googlesource.com/external/gyp.git tools/gyp \
    && ./gyp_llnode -Dlldb_dir=/usr/lib/llvm-3.7/ \
    && make -C out/ \
    && make install-linux

RUN mkdir -p /opt/examples
WORKDIR /opt/examples
COPY example.js /opt/examples/

CMD ["bash"]
