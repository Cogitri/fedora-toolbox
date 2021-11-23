FROM registry.fedoraproject.org/fedora-toolbox:35

COPY extra-packages /
RUN dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	&& dnf -y upgrade \
	&& dnf -y install $(<extra-packages)
RUN rm /extra-packages

RUN printf "Port 2222\nListenAddress localhost\nPermitEmptyPasswords yes\n" >> /etc/ssh/sshd_config \
	&& /usr/libexec/openssh/sshd-keygen rsa \
	&& /usr/libexec/openssh/sshd-keygen ecdsa \
	&& /usr/libexec/openssh/sshd-keygen ed25519

RUN curl -O https://gitlab.gnome.org/GNOME/libadwaita/-/archive/1.0.0.alpha.3/libadwaita-1.0.0.alpha.3.tar.gz \
	&& tar xf libadwaita-1.0.0.alpha.3.tar.gz\
	&& cd libadwaita-1.0.0.alpha.3 \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf libadwaita-1.0.0.alpha.3

RUN echo "/usr/local/lib64" > /etc/ld.so.conf.d/custom.conf \
	&& ldconfig

RUN dnf clean all

CMD /usr/bin/fish
