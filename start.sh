#!/bin/sh
# Démarre le service corosync
# corosync -f

# Exécute le script de configuration du mot de passe
if [ -n "$ROOT_PASSWORD" ]; then
  echo "root:$ROOT_PASSWORD" | chpasswd
else
  echo "root:pveqdevice" | chpasswd
fi

# Autorise la connexion ssh en tant que root
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Si la variable TZ est déclarée, configure la Time Zone
if [ -n "$TZ" ]; then
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
fi

# Lance le service SSH au démarrage du conteneur
exec /usr/sbin/sshd -D

