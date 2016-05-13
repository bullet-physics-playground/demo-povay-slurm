#!/usr/bin/env bash

#SBATCH -n 1
#SBATCH --ntasks-per-node=1
#SBATCH --time=00:30:00
#SBATCH --error=job.%J.err 
#SBATCH --output=job.%J.out

echo $(date +%s)
sleep 20
echo $(date +%s)
