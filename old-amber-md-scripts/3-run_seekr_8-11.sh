#!/bin/bash
#SBATCH --job-name="seekr_7-10"
#SBATCH --output="out/nirm_seekr.%j.%N.out"
#SBATCH --partition=gpuA100x4
#SBATCH --mem=220G
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --cpus-per-task=16
#SBATCH --constraint="scratch"
#SBATCH --gpus-per-node=4
#SBATCH --gpu-bind=closest
#SBATCH --account=kif-delta-gpu
#SBATCH --exclusive
#SBATCH --no-requeue
#SBATCH -t 47:30:00

source $HOME/.bashrc
conda activate SEEKR
export OPENMM_CUDA_COMPILER=`which nvcc`

SEEKR_DIR="$HOME/seekr2/seekr2"
PROJECT_ROOT_DIR="/scratch/kif/javingfun/mpro_nirm_seekr/root"
cd $PROJECT_ROOT_DIR

python $SEEKR_DIR/run.py 7 model.xml -c 0 &
python $SEEKR_DIR/run.py 8 model.xml -c 1 &
python $SEEKR_DIR/run.py 9 model.xml -c 2 &
python $SEEKR_DIR/run.py 10 model.xml -c 3 &
wait

sleep 60
