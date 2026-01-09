#!/bin/bash
#SBATCH --job-name="5LJJ_hidr"
#SBATCH --output="5LJJ_hidr.%j.%N.out"
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
#SBATCH -t 47:30:00

source $HOME/.bashrc
conda activate SEEKR3
export OPENMM_CUDA_COMPILER=`which nvcc`

cd /scratch/kif/lvotapka/TTK/5LJJ/roots

python ~/seekrtools/seekrtools/hidr/hidr.py any model.xml -p ../equilibrated_imaged.pdb -c 0 -k 50000 -v 0.00165

sleep 60
