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

ARG VERSION=3.5.0
RUN wget -q https://github.com/cdr/code-server/releases/download/v${VERSION}/code-server_${VERSION}_amd64.deb -O /code-server_${VERSION}_amd64.deb \
  && apt-get install -qy --no-install-recommends /code-server_${VERSION}_amd64.deb \
  && rm /code-server_${VERSION}_amd64.deb

RUN \
  # Fix loading of a wasm file which is assumed to live in node_modules.asar
  # https://github.com/CoenraadS/Bracket-Pair-Colorizer-2/blob/f4f5bf2795a2d4c81d4d423deca6af3533a30ff7/src/textMateLoader.ts#L117
  ln -s /usr/lib/code-server/lib/vscode/node_modules /usr/lib/code-server/lib/vscode/node_modules.asar

USER coder
COPY prince781.vala-1.0.3.vsix /prince781.vala-1.0.3.vsix
RUN mkdir -p /home/coder/project \
  && mkdir -p /home/coder/.local/share/code-server \
  && code-server --install-extension prince781.vala-1.0.3.vsix

EXPOSE 8080
ENV NODE_ENV=production
WORKDIR /home/coder/project
ENTRYPOINT [ "dumb-init", "code-server", "--host", "0.0.0.0" ]
