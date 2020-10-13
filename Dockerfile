FROM debian:testing-slim

RUN export user=coder \
  && groupadd -g 1000 -r $user && useradd -m -r -g 1000 -u 1000 $user

RUN apt-get update -q \
  && apt-get install -qy \
    ca-certificates \
    dumb-init \
    git \
    wget \
    valac \
    libgee-0.8-dev \
    libsoup2.4-dev \
    libjson-glib-dev \
    librest-dev \
    gnupg2 \
    meson \
    libgtk-3-dev \
    build-essential \
    curl \
    gettext \
    libgirepository1.0-dev \
    libsecret-1-dev \
    openssh-server \
    bash \
  && echo "deb http://ppa.launchpad.net/prince781/vala-language-server/ubuntu bionic main" > /etc/apt/sources.list.d/vala.list \
  && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys B13D6EF696260D322CC0980F3C7C9C4B21A1F479 \
  && apt-get update -q \
  && apt-get install -y vala-language-server \
  && rm -rf /var/lib/apt/lists/*

RUN wget https://download.gnome.org/sources/libhandy/1.0/libhandy-1.0.0.tar.xz \
  && tar xf libhandy-1.0.0.tar.xz \
  && cd libhandy-1.0.0 \
  && meson \
    --prefix=/usr \
    -Dprofiling=false \
    -Dintrospection=enabled \
    -Dgtk_doc=false \
    -Dtests=false \
    -Dexamples=false \
    -Dvapi=true \
    -Dglade_catalog=disabled \
    build \
  && ninja -C build install \
  && cd .. \
  && rm -r libhandy-1.0.0*

RUN curl https://sh.rustup.rs -sSf | sh -s -- -y

RUN mkdir /var/run/sshd \
  && mkdir /home/coder/.ssh \
  && chmod 700 /home/coder/.ssh
COPY authorized_keys /home/coder/.ssh/
RUN chmod 600 /home/coder/.ssh/authorized_keys \
  && chown -R coder:coder /home/coder/.ssh \
  && chsh -s /bin/bash coder

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
