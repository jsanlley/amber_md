#!/bin/bash
#SBATCH --job-name="1845_1"
#SBATCH --output="%j.%N.out"
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
#SBATCH -t 47:00:00

source $HOME/.bashrc
conda activate amber

cat > prod.mdin << EOF
#Run 250ns of NPT in AMBER
 &cntrl
  imin=0, ! flag to run md or minimization (p.340)
  ntx=5,   ! option to read initial coordinates (p.341),
  irest=0,! flag to restart a simulation anew or from a previous run (p.341)
  ntt=3, ! temperature regulation method in thermostat scheme (Langevin) (p.345)
  temp0=310.0,! reference temperature at which the system is kept (p.346)
  gamma_ln=5.0, ! collision frequency (pg. 347)
  dt=0.002, ! timestep in picoseconds (p.344)
  ntc=2, ! apply bond constraints using SHAKE (p. 349)
  ntf=2, ! force evaluation if SHAKE is not used (p. 360)
  ntb=2,  ! apply periodic boundary conditions to non-bonded int (p.360)
  ntp=1,  ! constant pressure dynamics (p.348)
  iwrap = 1 ! re-center atoms (p. 369 amber 22)
  barostat=1, ! Berendsen thermostat (p.348)
  cut=10.0, ! nonbonded cutoff in �~E (p.360)
  nstlim=250000000, ! number of MD steps to be performed (p.344)
  ntpr=250000, ! write to mdout and mdinfo files (p.342)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntwx=2500000, ! write coordinates to nc file (p.342)
  ntwr=250000, ! write to rst file
/
EOF
echo 'Running AMBER on $PWD'
pmemd.cuda -O -i prod.mdin -o mpro_prod.mdout -p mpro_solvated.prmtop -c mpro_equil.rst -r mpro_prod.rst -ref mpro_equil.rst -inf mpro_prod.info -x mpro_prod.nc
echo 'Done!'
rm prod.mdin

