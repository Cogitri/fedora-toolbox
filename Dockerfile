FROM registry.fedoraproject.org/fedora:33

ENV NAME=fedora-toolbox VERSION=33
LABEL com.github.containers.toolbox="true" \
      com.github.debarshiray.toolbox="true" \
      com.redhat.component="$NAME" \
      name="$FGC/$NAME" \
      version="$VERSION" \
      usage="This image is meant to be used with the toolbox command" \
      summary="Base image for creating Fedora toolbox containers" \
      maintainer="Debarshi Ray <rishi@fedoraproject.org>"

COPY README.md /

RUN sed -i '/tsflags=nodocs/d' /etc/dnf/dnf.conf

COPY missing-docs /
RUN dnf -y reinstall $(<missing-docs) && dnf upgrade -y
RUN rm /missing-docs

COPY extra-packages /
RUN dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	&& dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
	&& dnf -y install $(<extra-packages)
RUN rm /extra-packages

RUN printf "Port 2222\nListenAddress localhost\nPermitEmptyPasswords yes\n" >> /etc/ssh/sshd_config \
	&& /usr/libexec/openssh/sshd-keygen rsa \
	&& /usr/libexec/openssh/sshd-keygen ecdsa \
	&& /usr/libexec/openssh/sshd-keygen ed25519

RUN git clone https://github.com/benwaffle/vala-language-server \
	&& cd vala-language-server \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf vala-language-server

RUN git clone https://gitlab.gnome.org/exalm/libhandy -b gtk4 \
	&& cd libhandy \
	&& git checkout c425c1254e2f640ee28d746ac272e16bbc453b2b \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf libhandy

RUN git clone https://github.com/vala-lang/vala-lint \
	&& cd vala-lint \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf vala-lint

RUN wget https://github.com/libgit2/libgit2/releases/download/v1.1.0/libgit2-1.1.0.tar.gz \
	&& tar xf libgit2-1.1.0.tar.gz \
	&& cd libgit2-1.1.0 \
	&& cmake -G Ninja -B build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -r libgit2*

RUN git clone https://gitlab.alpinelinux.org/Leo/agl \
	&& cd agl \
	&& go build \
	&& mv agl /usr/local/bin/ \
	&& cd .. \
	&& rm -rf agl

RUN echo "/usr/local/lib64" > /etc/ld.so.conf.d/custom.conf \
	&& ldconfig

RUN dnf clean all

CMD /usr/bin/fish
