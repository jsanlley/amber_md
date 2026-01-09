#!/bin/bash
#SBATCH --job-name="8B2T_seekr"
#SBATCH --output="out/%j.%N.out"
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
#SBATCH -t 00:10:00

source $HOME/.bashrc
conda activate SEEKR
export OPENMM_CUDA_COMPILER=`which nvcc`

cd /scratch/kif/javingfun/mpro_nirm_seekr

python ~/seekrtools/seekrtools/hidr/hidr.py any seekr_mpro_nirm/model.xml -p mpro_solvated_openmm.pdb -c 0 -k 50000 -v 0.00165

sleep 60
