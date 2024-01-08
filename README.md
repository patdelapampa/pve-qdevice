# PVE-QDEVICE

## Why this image?
When using a 2-node Proxmox cluster, we need an additional device to provide a vote if one of the nodes becomes unavailable.
This is because the quorum system requires an odd number of devices to be able to vote.
Instead of attaching a new Proxmox node, this Docker image enables the creation of a container that can be declared as a qdevice and will be able to provide this additional vote.

## How to use it
### 1. Create a container using this image 
Execute the following command on a docker server
```bash
docker run -d --name=pve-qdevice -p 2222:22 -p 5404:5404 -p 5405:5405 -p 5406:5406 -e ROOT_PASSWORD=ChangeMe! -e TZ=Europe/Paris -v corosync_data:/etc/corosync patdelapampa/pve-qdevice
```
or use the following docker-compose.yml file:
```yaml
version: '3'

services:
  pve-qdevice:
    image: patdelapampa/pve-qdevice
    container_name: pve-qdevice
    ports:
      - "2222:22"
      - "5404:5404/udp"
      - "5405:5405/udp"
      - "5406:5406/udp"
    restart: always
    environment:
      - ROOT_PASSWORD=changeMe!    # Set the root user password. If not set, the default password is 'qdevice'
      - TZ=Europe/Paris

    volumes:
      - corosync_data:/etc/corosync

volumes:
  corosync_data:
    name: corosync_data
```

### 2. Install corosync-qdevice on each node of your Proxmox cluster
```bash
apt update && apt install corosync-qdevice -y
```

### 3. Configure the ssh port to use on the qdevice
Configure each cluster node to use the 2222 port when connecting to the qdevice container, adding the following lines zt the end of the `/root/.ssh/config` file
```bash
Host <DOCKER_SERVER_IPADDRESS>
  HostName <DOCKER_SERVER_IPADDRESS>
  Port 2222
  User root
```

### 4. Add the qdevice to the quorum
From any cluster node, execute:
```bash
pvecm qdevice setup <DOCKER_SERVER_IPADDRESS>
```

### 5. Testing
The `pvecm status` command should return an **odd** number of total votes.

Example:
```bash
root@pve:~# pvecm status
Cluster information
-------------------
Name:             pve-cluster
Config Version:   3
Transport:        knet
Secure auth:      on

Quorum information
------------------
Date:             Mon Jan  8 19:23:32 2024
Quorum provider:  corosync_votequorum
Nodes:            2
Node ID:          0x00000001
Ring ID:          1.1b
Quorate:          Yes

Votequorum information
----------------------
Expected votes:   3
Highest expected: 3
Total votes:      3
Quorum:           2  
Flags:            Quorate Qdevice 

Membership information
----------------------
    Nodeid      Votes    Qdevice Name
0x00000001          1    A,V,NMW 192.168.1.210 (local)
0x00000002          1    A,V,NMW 192.168.1.211
0x00000000          1            Qdevice

```
