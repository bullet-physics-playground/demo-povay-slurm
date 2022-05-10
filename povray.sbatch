#!/usr/bin/env bash

#SBATCH -N 1
#SBATCH -e /nfs/data/log/job-%A-%a.err
#SBATCH -o /nfs/data/log/job-%A-%a.out

#SBATCH --mail-user koppi
#SBATCH --mail-type ALL

SCENE=${1}
FRAMES=${2}

POVARGS="+W7680 +H4320 +A0.3 -J"

if [ -z "${SCENE}" ]; then
  echo "SCENE is unset or set to the empty string"
  exit 1
fi

WORKDIR=`pwd`/$SCENE-$SLURM_ARRAY_JOB_ID
FRAME=$SLURM_ARRAY_TASK_ID

mkdir -p $WORKDIR
cd $WORKDIR

echo "$SLURMD_NODENAME:$WORKDIR"
echo

PNG="$SCENE-$(printf "%07d" $FRAME).png"

time nice povray $SCENE.pov -L.. -V -D +KFI0 +KFF$FRAMES +SF$FRAME +EF$FRAME +wt$SLURM_CPUS_PER_TASK $POVARGS -O- > $WORKDIR/$PNG
