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

RUN sudo dnf builddep -y gtk4

RUN printf "Port 2222\nListenAddress localhost\nPermitEmptyPasswords yes\n" >> /etc/ssh/sshd_config \
	&& /usr/libexec/openssh/sshd-keygen rsa \
	&& /usr/libexec/openssh/sshd-keygen ecdsa \
	&& /usr/libexec/openssh/sshd-keygen ed25519

RUN curl -L -O https://ftp.acc.umu.se/pub/GNOME/sources/gtk/4.0/gtk-4.0.0.tar.xz \
	&& tar xf gtk-4.0.0.tar.xz \
	&& cd gtk-4.0.0 \
	&& meson build --prefix=/usr \
	&& ninja  -C build install \
	&& cd .. \
	&& rm -rf gtk-4.0.0 \
	&& sudo curl https://gitlab.gnome.org/GNOME/vala/-/raw/master/vapi/gtk4.vapi -o /usr/share/vala-0.48/vapi/gtk4.vapi

RUN git clone https://github.com/benwaffle/vala-language-server \
	&& cd vala-language-server \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf vala-language-server

RUN git clone https://gitlab.gnome.org/exalm/libhandy -b gtk4 \
	&& cd libhandy \
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

RUN echo "/usr/local/lib64" > /etc/ld.so.conf.d/custom.conf \
	&& ldconfig

RUN dnf clean all

CMD /usr/bin/fish
