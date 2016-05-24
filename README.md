[POV-Ray](http://www.povray.org) on [Slurm Workload Manager](https://en.wikipedia.org/wiki/Slurm_Workload_Manager) demo scripts

* https://www.youtube.com/watch?v=8lligATtAWs
* https://www.youtube.com/watch?v=NI8EPsuRrsU

### Setup a compute node on Ubuntu 16.04 in a SLURM cluster

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

Copy the ```/etc/munge/munge.key``` from another compute node in the cluster and check user, groups and permission flags:
```bash
# ls -al /etc/munge/munge.key
-r-------- 1 munge munge 1024 Mai 24 16:55 /etc/munge/munge.key
```

Restart the munge.service:
```bash
sudo systemctl restart munge
```

Test, that munge works:
```bash
munge -n | ssh <clusternode> unmunge
```

#### Install and setup slurmd

```bash
sudo apt -y install slurmd
```

The start of the slurmd.service will fail.

To fix this, edit the slurmd systemd unit file:
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


### Submit a test rendering job via run.sh

Render your first POV-Ray animation:
```bash
koppi@x200:~/data/demo-povay-slurm$ ./run.sh -s sphere
submitting job sphere.pov with 300 frames
 executing: sbatch --hint=compute_bound -n 1 -J povray -p debug -t 8:00:00 -O -J sphere -a 0-300 povray.sbatch sphere 300 '+A0.01 -J +W1280 +H720'
  * created povray job 33237  in /home/koppi/data/demo-povay-slurm/sphere-33237
 executing: sbatch --hint=compute_bound -n 1 -J povray -p debug -t 8:00:00 --job-name=ffmpeg --depend=afterok:33237 -D sphere-33237 sphere-33237/ffmpeg.sbatch
  * created ffmpeg job 33238 for /home/koppi/data/demo-povay-slurm/sphere-33237
done
```

Watch the job queue:
```bash
$ watch squeue 
             JOBID PARTITION     NAME     USER ST       TIME  NODES NODELIST(REASON)
    33237_[44-300]     debug   sphere    koppi PD       0:00      1 (Resources)
             33238     debug   ffmpeg    koppi PD       0:00      1 (Dependency)
          33237_43     debug   sphere    koppi  R       0:03      1 dell
          33237_42     debug   sphere    koppi  R       0:04      1 x220
          33237_41     debug   sphere    koppi  R       0:05      1 x200
```
