FROM debian:bookworm-slim
RUN echo 'debconf debconf/frontend select teletype' | debconf-set-selections
RUN apt-get update
RUN apt-get dist-upgrade -qy
RUN apt-get install -qy --no-install-recommends systemd systemd-sysv corosync-qnetd  openssh-server 
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/* /var/log/alternatives.log /var/log/apt/history.log /var/log/apt/term.log /var/log/dpkg.log
# Crée le répertoire pour la séparation des privilèges SSH
RUN mkdir -p /run/sshd \
	&& chmod 0755 /run/sshd \
	&& chown root:root /run/sshd
RUN chown -R coroqnetd:coroqnetd /etc/corosync/
RUN systemctl mask -- dev-hugepages.mount sys-fs-fuse-connections.mount
RUN rm -f /etc/machine-id /var/lib/dbus/machine-id
# Copie le script de démarrage
COPY start.sh /usr/local/bin/

# Rend les scripts exécutables
RUN chmod +x /usr/local/bin/start.sh


FROM debian:bookworm-slim
COPY --from=0 / /
ENV container docker
STOPSIGNAL SIGRTMIN+3
VOLUME [ "/sys/fs/cgroup", "/run", "/run/lock", "/tmp" ]
EXPOSE 22 5403
CMD ["/usr/local/bin/start.sh"]

