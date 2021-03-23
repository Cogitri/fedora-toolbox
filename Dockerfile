FROM registry.fedoraproject.org/fedora:34

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

RUN git clone https://github.com/benwaffle/vala-language-server \
	&& cd vala-language-server \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf vala-language-server

RUN git clone https://gitlab.gnome.org/exalm/libadwaita \
	&& cd libadwaita \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf libadwaita

RUN git clone https://github.com/vala-lang/vala-lint \
	&& cd vala-lint \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf vala-lint

RUN echo "/usr/local/lib64" > /etc/ld.so.conf.d/custom.conf \
	&& ldconfig

RUN curl -L -O https://download.gnome.org/sources/libsigc++/3.0/libsigc++-3.0.6.tar.xz \
  && tar xf libsigc++-3.0.6.tar.xz \
  && cd libsigc++-3.0.6 \
  && meson build \
  && ninja -C build install \
  && cd .. \
  && rm -rf libsigc++-3.0.6

RUN curl -L -O https://download.gnome.org/sources/glibmm/2.68/glibmm-2.68.0.tar.xz \
  && tar xf glibmm-2.68.0.tar.xz \
  && cd glibmm-2.68.0 \
  && meson build \
  && ninja -C build install \
  && cd .. \
  && rm -rf glibmm-2.68.0

RUN curl -L -O https://www.cairographics.org/releases/cairomm-1.16.0.tar.xz \
  && tar xf cairomm-1.16.0.tar.xz \
  && cd cairomm-1.16.0 \
  && meson build \
  && ninja -C build install \
  && cd .. \
  && rm -rf cairomm-1.16.0

RUN curl -L -O https://download.gnome.org/sources/pangomm/2.48/pangomm-2.48.0.tar.xz \
  && tar xf pangomm-2.48.0.tar.xz \
  && cd pangomm-2.48.0 \
  && meson build \
  && ninja -C build install \
  && cd .. \
  && rm -rf pangomm-2.48.0

RUN curl -L -O https://download.gnome.org/sources/gtkmm/4.0/gtkmm-4.0.1.tar.xz \
  && tar xf gtkmm-4.0.1.tar.xz \
  && cd gtkmm-4.0.1 \
  && meson build \
  && ninja -C build install \
  && cd .. \
  && rm -rf gtkmm-4.0.1

RUN dnf clean all

CMD /usr/bin/fish
