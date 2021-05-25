FROM registry.fedoraproject.org/fedora-toolbox:34

COPY extra-packages /
RUN dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
	&& dnf -y upgrade \
	&& dnf -y install $(<extra-packages)
RUN rm /extra-packages

RUN printf "Port 2222\nListenAddress localhost\nPermitEmptyPasswords yes\n" >> /etc/ssh/sshd_config \
	&& /usr/libexec/openssh/sshd-keygen rsa \
	&& /usr/libexec/openssh/sshd-keygen ecdsa \
	&& /usr/libexec/openssh/sshd-keygen ed25519

RUN git clone https://gitlab.gnome.org/exalm/libadwaita \
	&& cd libadwaita \
	&& meson build \
	&& ninja -C build install \
	&& cd .. \
	&& rm -rf libadwaita

RUN echo "/usr/local/lib64" > /etc/ld.so.conf.d/custom.conf \
	&& ldconfig

RUN dnf clean all

CMD /usr/bin/fish
