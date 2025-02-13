#!/bin/bash

# # of salts for monomeric system = ~ 52
# # of salts for dimeric system = ~64

#Make amber script to run minimization
cat > rmin.mdin << EOF  
#Run restrained minimization
 &cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=50.0, ! restraint weight (p.344)
  restraintmask=':1-614', ! specifies restrained atoms in system (p.344)
  maxcyc=10000, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=2500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

#Make amber script to run unrestrained minimization
cat > umin.mdin << EOF
#Run unrestrained minimization
 &cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1, ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  maxcyc=10000, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=2000, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

#Make amber script to run heating
cat > rheat.mdin << EOF
#Run 250ps of restrained heating (NVT)
 &cntrl
  imin=0,  ! flag to run md or minimization (p.340)
  ntx=1, ! option to read initial coordinates (p.341)
  ntpr=2500, ! write to mdout and mdinfo files (p.342)
  ntwr=2500, ! write to restrt file, alt. to nsltlim (p.342)
  ntwx=2500, ! write to mdcrd file for trajectory (p.342)
  ntf=2, ! force evaluation if SHAKE is not used (p. 360)
  ntc=2, ! apply bond constraints using SHAKE (p. 349)
  ntp=0, ! no constant pressure dynamics with isotropic position scaling Berendsen barostat (p.348)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntb=1, ! apply periodic boundary conditions to non-bonded int (p.360)
  nstlim=125000, ! 250ps number of MD steps to be performed (p.344)
  dt=0.002, ! timestep in picoseconds (p.344)
  cut=10.0, ! nonbonded cutoff in Å (p.360)
  iwrap=1
  tempi=0,
  temp0=310.0, ! reference temperature at which the system is kept (p.346)
  ntt=3, ! temperature regulation method in thermostat scheme (Langevin) (p.345)
  gamma_ln=5.0, ! collision frequency (pg. 347)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=5.0, ! restraint weight (p.344)
  restraintmask=':1-614', ! specifies restrained atoms in system (p.344)
/
EOF

#Make amber script to run unrestrained heating 250ps
cat > heat.mdin << EOF
#Run 250ps of unrestrained heating
 &cntrl
  imin=0,  ! flag to run md or minimization (p.340)
  ntx=1, ! option to read initial coordinates (p.341)
  ntpr=2500, ! write to mdout and mdinfo files (p.342)
  ntwr=2500, ! write to restrt file, alt. to nsltlim (p.342)
  ntwx=2500, ! write to mdcrd file for trajectory (p.342)
  ntf=2, ! force evaluation if SHAKE is not used (p. 360)
  ntc=2, ! apply bond constraints using SHAKE (p. 349)
  ntp=0, ! no constant pressure dynamics with isotropic position scaling Berendsen barostat (p.348)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntb=1, ! apply periodic boundary conditions to non-bonded int (p.360)
  nstlim=125000, ! 250ps number of MD steps to be performed (p.344)
  dt=0.002, ! timestep in picoseconds (p.344)
  cut=10.0, ! nonbonded cutoff in Å (p.360)
  iwrap=1
  tempi=0,
  temp0=310.0, ! reference temperature at which the system is kept (p.346)
  ntt=3, ! temperature regulation method in thermostat scheme (Langevin) (p.345)
  gamma_ln=5.0, ! collision frequency (pg. 347)
/
EOF

#Make amber script to run equilibration 250ps
cat > requil.mdin << EOF
#Run restrained NPT equilibration
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
  nstlim=125000, ! 250ps number of MD steps to be performed (p.344)
  ntpr=25000, ! 50ps write to mdout and mdinfo files (p.342)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntwx=25000, ! 50ps write coordinates to nc file (p.342)
  ntwr=25000, ! 50ps write to rst file
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=5.0, ! restraint weight (p.344)
  restraintmask=':1-614', ! specifies restrained atoms in system (p.344)
/
EOF

#Make amber script to run restrained equilibration 250ps
cat > equil.mdin << EOF
#Run unrestrained equilibration
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
  nstlim=125000, ! 250ps number of MD steps to be performed (p.344)
  ntpr=2500, ! 5ps write to mdout and mdinfo files (p.342)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntwx=2500, ! 5ps write coordinates to nc file (p.342)
  ntwr=2500, ! 5ps write to rst file
/
EOF

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

#Make run script to run production from local machine
cat > run_prod.sh << EOF
#!/bin/bash
module load amber

pmemd.cuda -O -i prod.mdin -o $1_prod1.mdout -p $1_solvated.prmtop -c $1_equil.rst -r $1_prod1.rst -ref $1_equil.rst -inf $1_prod1.info -x $1_prod1.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod2.mdout -p $1_solvated.prmtop -c $1_prod1.rst -r $1_prod2.rst -ref $1_prod1.rst -inf $1_prod2.info -x $1_prod2.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod3.mdout -p $1_solvated.prmtop -c $1_prod2.rst -r $1_prod3.rst -ref $1_prod2.rst -inf $1_prod3.info -x $1_prod3.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod4.mdout -p $1_solvated.prmtop -c $1_prod3.rst -r $1_prod4.rst -ref $1_prod3.rst -inf $1_prod4.info -x $1_prod4.nc
EOF

#Make slurm script for running production runs
cat > run_prod.slurm << EOF
#!/bin/bash
#SBATCH --job-name=prod1_1_$1
#SBATCH --output=$1_%j.out
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
#SBATCH -t 47:00:00

set -xv
source $HOME/.bashrc
conda activate amber

pmemd.cuda -O -i prod.mdin -o $1_prod1.mdout -p $1_solvated.prmtop -c $1_equil.rst -r $1_prod1.rst -ref $1_equil.rst -inf $1_prod1.info -x $1_prod1.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod2.mdout -p $1_solvated.prmtop -c $1_prod1.rst -r $1_prod2.rst -ref $1_prod1.rst -inf $1_prod2.info -x $1_prod2.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod3.mdout -p $1_solvated.prmtop -c $1_prod2.rst -r $1_prod3.rst -ref $1_prod2.rst -inf $1_prod3.info -x $1_prod3.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod4.mdout -p $1_solvated.prmtop -c $1_prod3.rst -r $1_prod4.rst -ref $1_prod3.rst -inf $1_prod4.info -x $1_prod4.nc
EOF

#Make run script to run from local machine
cat > run_prep.sh << EOF
#!/bin/bash
module load amber

echo 'Running rmin'
pmemd.cuda -O -i rmin.mdin -o $1_rmin.mdout -p $1_solvated.prmtop -c $1_solvated.inpcrd -r $1_rmin.rst -ref $1_solvated.inpcrd -inf $1_rmin.info
wait
echo 'Running min'
pmemd.cuda -O -i umin.mdin -o $1_umin.mdout -p $1_solvated.prmtop -c $1_rmin.rst -r $1_umin.rst -ref $1_rmin.rst -inf $1_rmin.info
wait
echo 'Running rheat'
pmemd.cuda -O -i rheat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_umin.rst -r $1_rheat.rst -ref $1_umin.rst -inf $1_rheat.info -x $1_rheat.nc
wait
echo 'Running heat'
pmemd.cuda -O -i heat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_rheat.rst -r $1_heat.rst -ref $1_rheat.rst -inf $1_heat.info -x $1_heat.nc
wait
echo 'Running requil'
pmemd.cuda -O -i requil.mdin -o $1_requil.mdout -p $1_solvated.prmtop -c $1_heat.rst -r $1_requil.rst -ref $1_heat.rst -inf $1_requil.info -x $1_requil.nc
wait
echo 'Running equil'
pmemd.cuda -O -i equil.mdin -o $1_equil.mdout -p $1_solvated.prmtop -c $1_requil.rst -r $1_equil.rst -ref $1_requil.rst -inf $1_equil.info -x $1_equil.nc
EOF


#Make slurm script to run all commands
cat > run_prep.slurm << EOF
#!/bin/bash
#SBATCH --job-name=prep_$1
#SBATCH --output=$1_prep_%j.out
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
#SBATCH -t 2:00:00

set -xv
source $HOME/.bashrc
conda activate amber

pmemd.cuda -O -i rmin.mdin -o $1_rmin.mdout -p $1_solvated.prmtop -c $1_solvated.inpcrd -r $1_rmin.rst -ref $1_solvated.inpcrd -inf $1_rmin.info
pmemd.cuda -O -i umin.mdin -o $1_umin.mdout -p $1_solvated.prmtop -c $1_rmin.rst -r $1_umin.rst -ref $1_rmin.rst -inf $1_rmin.info
pmemd.cuda -O -i rheat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_umin.rst -r $1_rheat.rst -ref $1_umin.rst -inf $1_rheat.info -x $1_rheat.nc
pmemd.cuda -O -i heat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_rheat.rst -r $1_heat.rst -ref $1_rheat.rst -inf $1_heat.info -x $1_heat.nc
pmemd.cuda -O -i requil.mdin -o $1_requil.mdout -p $1_solvated.prmtop -c $1_heat.rst -r $1_requil.rst -ref $1_heat.rst -inf $1_requil.info -x $1_requil.nc
pmemd.cuda -O -i equil.mdin -o $1_equil.mdout -p $1_solvated.prmtop -c $1_requil.rst -r $1_equil.rst -ref $1_requil.rst -inf $1_equil.info -x $1_equil.nc
EOF


#make cpptraj script to align and visualize equilibration run
cat > combine_equil.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_equil.nc 
autoimage
rms fit :1-612
trajout $1_equil_aligned.nc
trajout $1_equil.pdb pdb onlyframes 50 50 1
EOF


#make cpptraj script to align and visualize equilibration run
cat > combine_prod.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_prod1.nc 1 last 10
trajin $1_prod2.nc 1 last 10
trajin $1_prod3.nc 1 last 10
trajin $1_prod4.nc 1 last 10
autoimage
rms fit :1-612
trajout $1_prod_aligned.nc
EOF

#Make cleanup file to sort files into directories and also make replica files
cat > cleanup.sh << EOF
#!/bin/bash

mkdir prod
mkdir prod/1
cp *prmtop prod/1
cp *_equil.rst prod/1
cp *equil_aligned.nc prod/1
cp *prod.* prod/1

cp -r prod/1 prod/2
cp -r prod/2 prod/3

mkdir prep
mkdir prep/min
mv *min* prep/min
mkdir prep/heat
mv *heat* prep/heat
mkdir prep/equil
mv *equil* prep/equil
mv *_prep* prep/

mkdir parm
mkdir parm/antechamber
mv *antechamber* parm/antechamber
mv *A* parm/antechamber
mv sqm* parm/antechamber
mv 7YY* parm

mkdir parm/tleap
mv *leap* parm/tleap
mv *solvated* parm/tleap

rm cleanup.sh
rm *prod.*
EOF
