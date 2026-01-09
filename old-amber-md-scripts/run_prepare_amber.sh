#!/bin/bash
#SBATCH --job-name="Amber"
#SBATCH --output="run_prepare_%j.out"
#SBATCH --partition=gpuA100x4
#SBATCH --mem=55G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --constraint="scratch"
#SBATCH --gpus-per-node=1
#SBATCH --gpu-bind=closest
#SBATCH --account=kif-delta-gpu
#SBATCH --no-requeue
#SBATCH -t 24:00:00

source $HOME/.bashrc
SCRIPTS='/scratch/kif/javingfun/scripts'
conda activate amber

cd 1-min
echo 'Minimizing in $PWD...'
. $SCRIPTS/run_min.sh F2459-2036
wait 

cd ../2-heat
echo 'Heating in $PWD...'
. $SCRIPTS/scripts/run_heat.sh F2459-2036
wait

cd ../3-equil
echo 'Equilibrating in $PWD...'
. $SCRIPTS/scripts/run_equil.sh F2459-2036
wait

cd ../
echo "Done!"
