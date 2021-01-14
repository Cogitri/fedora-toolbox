FROM registry.fedoraproject.org/fedora:33

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

RUN curl -L -O https://ftp.acc.umu.se/pub/GNOME/sources/gtk/4.0/gtk-4.0.1.tar.xz \
	&& tar xf gtk-4.0.1.tar.xz \
	&& cd gtk-4.0.1 \
	&& meson build --prefix=/usr \
	&& ninja  -C build install \
	&& cd .. \
	&& rm -rf gtk-4.0.1 \
	&& sudo curl https://gitlab.gnome.org/GNOME/vala/-/raw/master/vapi/gtk4.vapi -o /usr/share/vala-0.48/vapi/gtk4.vapi

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

RUN dnf clean all

CMD /usr/bin/fish
