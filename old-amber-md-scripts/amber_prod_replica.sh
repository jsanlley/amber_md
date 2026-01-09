#!/bin/bash
#SBATCH --job-name="mpro_"$1
#SBATCH --output="1845_2.out"
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
module load conda
module load amber


#This script runs 250ns of amber per run
cat > prod.mdin << EOF
#Run 250ns of NPT in AMBER
 &cntrl
  imin=0, 		! flag to run md or minimization (p.340)
  ntx=5,   		! option to read initial coordinates (p.341),
  irest=0,		! flag to restart a simulation anew or from a previous run (p.341)
  ntt=3, 		! temperature regulation method in thermostat scheme (Langevin) (p.345)
  temp0=310.0,		! reference temperature at which the system is kept (p.346)
  gamma_ln=5.0, 	! collision frequency (pg. 347)
  dt=0.002, 		! timestep in picoseconds (p.344)
  ntc=2, 		! apply bond constraints using SHAKE (p. 349)
  ntf=2, 		! force evaluation if SHAKE is not used (p. 360)
  ntb=2,  		! apply periodic boundary conditions to non-bonded int (p.360)
  ntp=1,  		! constant pressure dynamics (p.348)
  iwrap = 1 		! re-center atoms (p. 369 amber 22)
  barostat=1, 		! Berendsen thermostat (p.348)
  cut=10.0, 		! nonbonded cutoff in �~E (p.360)
  nstlim=125000000, 	! number of MD steps to be performed (p.344)
  ntpr=250000, 		! write to mdout and mdinfo files (p.342)
  nscm=1000, 		! removal of transaltional and rotational center of mass (p. 344)
  ntwx=10000, 		! write coordinates to nc file (p.342)
  ntwr=250000, 		! write to rst file
/
EOF

echo "Running AMBER on $PWD"

if [ $2 -eq 1 ]
then
	#run 250ns of production from equilibration
	echo 'Starting run '$2
	pmemd.cuda -O -i prod.mdin -o mpro_$1_$2.mdout -p mpro_$1_solvated.prmtop -c mpro_$1_equil.rst -r mpro_$1_prod_$2.rst -ref mpro_$1_equil.rst -inf mpro_$1_prod_$2.info -x mpro_$1_prod_$2.nc

elif [ $2 -eq 2 ]
then
	#run 250ns from prod1
	echo 'Starting run '$2
	pmemd.cuda -O -i prod.mdin -o mpro_$1_prod_$2.mdout -p mpro_$1_solvated.prmtop -c mpro_$1_prod_1.rst -r mpro_$1_prod_$2.rst -ref mpro_$1_prod_1.rst -inf mpro_$1_prod_$2.info -x mpro_$1_prod_$2.nc

elif [ $2 -eq 3 ]
then
	#run 250ns from prod2
	echo 'Starting run '$2
	pmemd.cuda -O -i prod.mdin -o mpro_$1_prod_$2.mdout -p mpro_$1_solvated.prmtop -c mpro_$1_prod_2.rst -r mpro_$1_prod_$2.rst -ref mpro_$1_prod_2.rst -inf mpro_$1_prod_$2.info -x mpro_$1_prod_$2.nc

elif [ $2 -eq 4 ]
then
	#run 250ns from prod3
	echo 'Starting run '$2
	pmemd.cuda -O -i prod.mdin -o mpro_$1_prod_$2.mdout -p mpro_$1_solvated.prmtop -c mpro_$1_prod_3.rst -r mpro_$1_prod_$2.rst -ref mpro_$1_prod_3.rst -inf mpro_$1_prod_$2.info -x mpro_$1_prod_$2.nc
fi

rm prod.mdin
