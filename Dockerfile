# Utilise l'image Debian Bookworm slim comme base
FROM debian:bookworm-slim

# Installe les packages nécessaires
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    openssh-server corosync-qnetd && \
    rm -rf /var/lib/apt/lists/*

# Crée un répertoire pour stocker les données de corosync
RUN mkdir -p /var/lib/corosync

# Crée le répertoire pour la séparation des privilèges SSH
RUN mkdir -p /run/sshd \
	&& chmod 0755 /run/sshd \
	&& chown root:root /run/sshd

# Copie le script de démarrage
COPY start.sh /usr/local/bin/

# Rend les scripts exécutables
RUN chmod +x /usr/local/bin/start.sh

# Exposer les ports nécessaires
EXPOSE 22 5403 5404/udp 5405/udp 5406/udp

# Démarre automatiquement le service SSH lors de la création du conteneur
# RUN service ssh start

# Utilise le script de démarrage comme commande d'initialisation
CMD ["/usr/local/bin/start.sh"]
