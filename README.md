[POV-Ray](http://www.povray.org) on [Slurm Workload Manager](https://en.wikipedia.org/wiki/Slurm_Workload_Manager) demo scripts

* https://www.youtube.com/watch?v=8lligATtAWs
* https://www.youtube.com/watch?v=NI8EPsuRrsU

### Setup compute node on Ubuntu 16.04 in a SLURM cluster

* make, povray, ffmpeg
* munged
* slurmd
* nfs client

#### Install make, povray and ffmpeg

```bash
sudo apt -y install make povray povray-examples ffmpeg
```

#### Install and setup munged

```bash
sudo apt -y install munge
```

The start of the munge.service will fail, you have to make a little change:
```bash
sudo systemctl edit --system --full munge
```

Change the ```ExecStart``` line to read:
```ini
ExecStart=/usr/sbin/munged --force
```

Copy the ```/etc/munge/munge.key``` from your another node and check user, groups and permission flags:
```bash
# ls -al /etc/munge/munge.key
-r-------- 1 munge munge 1024 Mai 24 16:55 /etc/munge/munge.key
```

Restart the munge.service:
```bash
sudo systemctl restart munge
```

Test that munge works:
```bash
munge -n | ssh <clusternode> unmunge
```

#### Install and setup slurmd

```bash
sudo apt -y install slurmd
```

The start of the slurmd.service will fail.

Edit the slurmd systemd unit file:
```bash
sudo systemctl edit --system --full slurmd
```
And change from:
```ini
[Service]
Type=forking
EnvironmentFile=/etc/default/slurmd
ExecStart=/usr/sbin/slurmd $SLURMD_OPTIONS
PIDFile=/var/run/slurm-llnl/slurmd.pid
```
to:
```ini
[Service]
Type=simple
EnvironmentFile=/etc/default/slurmd
ExecStart=/usr/sbin/slurmd $SLURMD_OPTIONS -cD
PIDFile=/var/run/slurm-llnl/slurmd.pid
```

Next, copy ```/etc/slurm-llnl/slurm.conf``` from another node in your cluster.

Restart, check and enable the slurmd.service:
```bash
sudo systemctl restart slurmd.service
sudo systemctl status  slurmd.service
sudo systemctl enable  slurmd.service
```

Restart the slurmctld.service on your slurmctld node:
```bash
sudo systemctl restart slurmctld.service
```

Check the node's slurmd status with sview:
```bash
sview
```

#### Setup NFS

```bash
sudo apt -y install nfs-common
sudo mkdir -p /nfs/data
```

Edit ```/etc/fstab```
```ini
192.168.0.113:/data /nfs/data nfs auto,noatime,nolock,bg,nfsvers=4,intr,tcp,actimeo=1800,rsize=8192,wsize=8192 0
```

```bash
sudo mount /nfs/data
```
