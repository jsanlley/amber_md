#!/bin/bash
#Make amber script to run NVT production for 250ns
cat > prod.mdin << EOF
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
  iwrap = 1, ! re-center atoms (p. 369 amber 22)
  barostat=1, ! Berendsen thermostat (p.348)
  cut=10.0, ! nonbonded cutoff in Å (p.360)
  nstlim=125000000, ! 250ns number of MD steps to be performed (p.344)
  ntpr=50000, ! 250ps write 2500 frames to mdout and mdinfo files (p.342)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntwx=50000, ! 250ps write 2500 frames coordinates to nc file (p.342)
  ntwr=50000, ! 250ps write 2500 frames rst file
/
EOF

#Make slurm script for running production runs
cat > run_prod.slurm << EOF
#!/bin/bash
#SBATCH --job-name=$2_0_0
#SBATCH --output=$1_prod_rep_run_abv_%j.out
#SBATCH --partition=gpuA100x4
#SBATCH --mem=16g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --constraint="scratch"
#SBATCH --gpus-per-node=1
#SBATCH --gpu-bind=closest
#SBATCH --account=kif-delta-gpu
#SBATCH --no-requeue
#SBATCH -t 42:00:00

set -xv
source $HOME/.bashrc
conda activate amber

pmemd.cuda -O -i prod.mdin -o $1_prod1.mdout -p $1_solvated.prmtop -c $1_equil.rst -r $1_prod1.rst -ref $1_equil.rst -inf $1_prod1.info -x $1_prod1.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod2.mdout -p $1_solvated.prmtop -c $1_prod1.rst -r $1_prod2.rst -ref $1_prod1.rst -inf $1_prod2.info -x $1_prod2.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod3.mdout -p $1_solvated.prmtop -c $1_prod2.rst -r $1_prod3.rst -ref $1_prod2.rst -inf $1_prod3.info -x $1_prod3.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod4.mdout -p $1_solvated.prmtop -c $1_prod3.rst -r $1_prod4.rst -ref $1_prod3.rst -inf $1_prod4.info -x $1_prod4.nc
EOF
