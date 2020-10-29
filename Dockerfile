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
RUN dnf -y reinstall $(<missing-docs)
RUN rm /missing-docs

COPY extra-packages /
RUN dnf -y install $(<extra-packages)
RUN rm /extra-packages

RUN git clone https://github.com/benwaffle/vala-language-server \
	&& cd vala-language-server \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -r vala-language-server

RUN git clone https://gitlab.gnome.org/exalm/libhandy -b gtk4 \
	&& cd libhandy \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -r libhandy

RUN dnf clean all

CMD /usr/bin/fish
