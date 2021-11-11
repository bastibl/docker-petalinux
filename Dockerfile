FROM ubuntu:20.04

MAINTAINER rikyborg <44963821+rikyborg@users.noreply.github.com>

# for build and run see README.md

# install dependences:

ARG UBUNTU_MIRROR
RUN [ -z "${UBUNTU_MIRROR}" ] || sed -i.bak s/archive.ubuntu.com/${UBUNTU_MIRROR}/g /etc/apt/sources.list 

RUN apt-get update &&  DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
  autoconf \
  automake \
  bc \
  bison \
  build-essential \
  chrpath \
  cpio \
  debianutils \
  diffstat \
  expect \
  flex \
  gawk \
  gcc \
  gcc-multilib \
  git \
  git-core \
  gnupg \
  gzip \
  iproute2 \
  iputils-ping \
  kmod \
  lib32z1-dev \
  libegl1-mesa \
  libglib2.0-dev \
  libgtk2.0-0 \
  libidn11 \
  libncurses5-dev \
  libsdl1.2-dev \
  libselinux1 \
  libssl-dev \
  libtinfo5 \
  libtool \
  libtool-bin \
  locales \
  lsb-release \
  make \
  net-tools \
  pax \
  pylint3 \
  python \
  python3 \
  python3-git \
  python3-jinja2 \
  python3-pexpect \
  python3-pip \
  rsync \
  screen \
  socat \
  sudo \
  tar \
  texinfo \
  tftpd \
  tofrodos \
  u-boot-tools \
  unzip \
  update-inetd \
  wget \
  xterm \
  xvfb \
  xxd \
  xz-utils \
  zlib1g-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN dpkg --add-architecture i386 &&  apt-get update &&  \
      DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
      zlib1g:i386 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


ARG PETA_VERSION
ARG PETA_RUN_FILE

RUN locale-gen en_US.UTF-8 && update-locale

#make a Vivado user
RUN adduser --disabled-password --gecos '' vivado && \
  usermod -aG sudo vivado && \
  echo "vivado ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY accept-eula.sh ${PETA_RUN_FILE} /

# run the install
RUN chmod a+rx /${PETA_RUN_FILE} && \
  chmod a+rx /accept-eula.sh && \
  mkdir -p /opt/Xilinx && \
  chmod 777 /tmp /opt/Xilinx && \
  cd /tmp && \
  sudo -u vivado -i /accept-eula.sh /${PETA_RUN_FILE} /opt/Xilinx/petalinux && \
  rm -f /${PETA_RUN_FILE} /accept-eula.sh

# make /bin/sh symlink to bash instead of dash:
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

USER vivado
ENV HOME /home/vivado
ENV LANG en_US.UTF-8
RUN mkdir /home/vivado/projects
WORKDIR /home/vivado/projects

#add vivado tools to path
RUN echo "source /opt/Xilinx/petalinux/settings.sh" >> /home/vivado/.bashrc
