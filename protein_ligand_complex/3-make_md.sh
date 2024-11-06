#!/bin/bash

# This script will write the necessary amber input files for all stages of the simulations (minimization, heating, equilibration, and production)

# Before running make sure you include the necessary flags
# $1 length of protein (ex. 306 for mpro)
# $2 ligand residue number
# $3 protein-ligand pdb name (no pdb)

# More information on the option included in the AMBER manual

# Make prep files
mkdir prep

# Make min files, copy necessary files
mkdir prep/min
cp parm/tleap/*solvated.prmtop prep/min
cp parm/tleap/*solvated.pdb prep/min
cp parm/tleap/*solvated.inpcrd prep/min

# MINIMIZATION

echo 'Creating mininization files'

# Make input scripts to run minimization

# Min 1: Strong minimization (100 kcal/mol) on all non-hydrogen atoms
# Min 2: Moderate restraint (50 kcal/mol) on all non-hydrogen atoms
# Min 3: Soft restraint (10 kcal/mol) on non-hydrogen proteinogenic atoms
# Min 4: Soft restraint (10 kcal/mol) on non-hydrogen ligand atoms
# Min 5: Unrestrained minimization on all atoms

cat > prep/min/min1.mdin << EOF  
#strong minimization on non hydrogen atomsm 
&cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=100.0, ! kcal/mol restraint weight (p.344)
  restraintmask='!@H=', ! strong restraint on all non-hydrogen atoms (p.344)
  maxcyc=500, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

cat > prep/min/min2.mdin << EOF
#moderate minimization on protein atoms
&cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=50.0, ! kcal/mol restraint weight (p.344)
  restraintmask=':1-$1 & !@H=', ! strong restraint on all non-hydrogen atoms (p.344)
  maxcyc=500, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

cat > prep/min/min3.mdin << EOF
#soft minimization on backbone heavy atoms
 &cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=10.0, ! kcal/mol restraint weight (p.344)
  restraintmask=':1-$1@CA,N,C,O,S & !@H=', ! moderate restraint on all non-hydrogen atoms (p.344)
  maxcyc=500, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

cat > prep/min/min4.mdin << EOF
#soft minimization on ligand heavy atoms
 &cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=10.0, ! kcal/mol restraint weight (p.344)
  restraintmask=':$2 & !@H=', ! soft restraint on all non-hydrogen atoms (p.344)
  maxcyc=500, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

cat > prep/min/min5.mdin << EOF
#Run unrestrained minimization
 &cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1, ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  maxcyc=40000, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ! ncyc=2000, switching from steepest descent to conjugate gradient (p.344)
/
EOF

# Make script that will exectute commands to run minimization 

cat > prep/min/run_min.sh << EOF
#!/bin/bash
module load amber

echo 'Running minimization 1/5'
pmemd.cuda -O -i min1.mdin -o $3_min1.mdout -p $3_solvated.prmtop -c $3_solvated.inpcrd -r $3_min1.rst -ref $3_solvated.inpcrd -inf $3_min1.info

echo 'Running minimization 2/5'
pmemd.cuda -O -i min2.mdin -o $3_min2.mdout -p $3_solvated.prmtop -c $3_min1.rst -r $3_min2.rst -ref $3_min1.rst -inf $3_min2.info

echo 'Running minimization 3/5'
pmemd.cuda -O -i min3.mdin -o $3_min3.mdout -p $3_solvated.prmtop -c $3_min2.rst -r $3_min3.rst -ref $3_min2.rst -inf $3_min3.info

echo 'Running minimization 4/5'
pmemd.cuda -O -i min4.mdin -o $3_min4.mdout -p $3_solvated.prmtop -c $3_min3.rst -r $3_min4.rst -ref $3_min3.rst -inf $3_min4.info

echo 'Running minimization 5/5'
pmemd.cuda -O -i min5.mdin -o $3_min5.mdout -p $3_solvated.prmtop -c $3_min4.rst -r $3_min5.rst -ref $3_min4.rst -inf $3_min5.info

# Copy necessary files to heating directory
cp *solvated.prmtop ../heat 
cp *min5.rst ../heat

# Create a representative pdb file of minimized strucure
ambpdb -p $3_solvated.prmtop -c $3_min5.rst > $3_minimized.pdb

# Run analysis script to visualize extent of minimization
# TBD
EOF

# Make heat directory and copy necessary files
mkdir prep/heat

# HEATING

echo 'Creating heating files'
# Make input scripts to run heating at constant volume (NVT)

# Heat 1: Heat to 310K over 250ps with soft restraints (5 kcal/mol)
# Heat 2: Run at 310K for 250ps with no restraints

cat > prep/heat/rheat.mdin << EOF
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
  restraintmask=':1-$1 & :$2', ! specifies restrained atoms in system (p.344)
/
EOF

cat > prep/heat/heat.mdin << EOF
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
  tempi=310.0,
  temp0=310.0, ! reference temperature at which the system is kept (p.346)
  ntt=3, ! temperature regulation method in thermostat scheme (Langevin) (p.345)
  gamma_ln=5.0, ! collision frequency (pg. 347)
/
EOF

# Make script that will exectute commands to run heating

cat > prep/heat/run_heat.sh << EOF
#!/bin/bash
module load amber

echo 'Running rheat'
pmemd.cuda -O -i rheat.mdin -o $3_rheat.mdout -p $3_solvated.prmtop -c $3_min5.rst -r $3_rheat.rst -ref $3_min5.rst -inf $3_rheat.info -x $3_rheat.nc

echo 'Running heat'
pmemd.cuda -O -i heat.mdin -o $3_heat.mdout -p $3_solvated.prmtop -c $3_rheat.rst -r $3_heat.rst -ref $3_rheat.rst -inf $3_heat.info -x $3_heat.nc

# Copy necessary files to the equilibration directory
cp *solvated.prmtop ../equil
cp *_heat.rst ../equil

# Create pdb file of the representative strucutre
ambpdb -p $3_solvated.prmtop -c $3_heat.rst > $3_heated.pdb

# Run analysis script to check heating parameters
# TBD
EOF


# Make equilibration file
mkdir prep/equil

# EQUILIBRATION 

echo 'Creating equilibration files'
# Make input scripts to run equilibration at constant pressure (NPT)

# Equil 1: Run at 310K for 250ps with soft restraints (5 kcal/mol)
# Equil 2: Run at 310K for 250ps with no restraints 

cat > prep/equil/requil.mdin << EOF
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
  nstlim=250000, ! 500ps number of MD steps to be performed (p.344)
  ntpr=25000, ! 50ps write to mdout and mdinfo files (p.342)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntwx=25000, ! 50ps write coordinates to nc file (p.342)
  ntwr=25000, ! 50ps write to rst file
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=5.0, ! restraint weight (p.344)
  restraintmask=':1-$1 & :$2', ! specifies restrained atoms in system (p.344)
/
EOF

cat > prep/equil/equil.mdin << EOF
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
  nstlim=250000, ! 500ps number of MD steps to be performed (p.344)
  ntpr=2500, ! 5ps write to mdout and mdinfo files (p.342)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntwx=2500, ! 5ps write coordinates to nc file (p.342)
  ntwr=2500, ! 5ps write to rst file
/
EOF

# Make script that will exectute commands to run equilibration 

cat > prep/equil/run_equil.sh << EOF
#!/bin/bash
module load amber

echo 'Running requil'
pmemd.cuda -O -i requil.mdin -o $3_requil.mdout -p $3_solvated.prmtop -c $3_heat.rst -r $3_requil.rst -ref $3_heat.rst -inf $3_requil.info -x $3_requil.nc

echo 'Running equil'
pmemd.cuda -O -i equil.mdin -o $3_equil.mdout -p $3_solvated.prmtop -c $3_requil.rst -r $3_equil.rst -ref $3_requil.rst -inf $3_equil.info -x $3_equil.nc

# Copy restart file from equilibration to production directory
cp *_equil.rst ../../prod/1
cp *solvated.prmtop ../../prod/1

# Create pdb file of the representative strucutre
ambpdb -p $3_solvated.prmtop -c $3_equil.rst > $3_equilibrated.pdb

# Run analysis script to check equilibration
cpptraj -i process_equil.cpptraj
# TBD

EOF

#make cpptraj script to align and visualize equilibration run
cat > prep/equil/process_equil.cpptraj << EOF
parm $3_solvated.prmtop
trajin $3_equil.nc

autoimage
rms fit :1-$1@CA

trajout $3_equil_aligned.nc
trajout $3_equilibrated.pdb pdb onlyframes 50 50 1
EOF



# Make prod files
mkdir prod
mkdir prod/1

# PRODUCTION

echo 'Creating production files'
# Make scripts that will execute commands for production runs (4 x 250ns in triplicates). Also makes a submission file for SLURM jobs.

#Make amber script to run NVT production for 250ns
cat > prod/1/prod.mdin << EOF
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
  ntpr=250000, !  500ps resolution to mdout/mdinfo (500 steps)  (p.342)
  nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
  ntwx=50000, ! 100ps/frame resolution to traj (2,500 frames) (p.342)
  ntwr=50000, !  100ps/frame resolution to rst (2,500 frames) 
/
EOF

# Execute the commands to run production (change every run)
cat > prod/1/run_prod.sh << EOF
#!/bin/bash
module load amber

pmemd.cuda -O -i prod.mdin -o $3_prod1.mdout -p $3_solvated.prmtop -c $3_equil.rst -r $3_prod1.rst -ref $3_equil.rst -inf $3_prod1.info -x $3_prod1.nc
#pmemd.cuda -O -i prod.mdin -o $3_prod2.mdout -p $3_solvated.prmtop -c $3_prod1.rst -r $3_prod2.rst -ref $3_prod1.rst -inf $3_prod2.info -x $3_prod2.nc
#pmemd.cuda -O -i prod.mdin -o $3_prod3.mdout -p $3_solvated.prmtop -c $3_prod2.rst -r $3_prod3.rst -ref $3_prod2.rst -inf $3_prod3.info -x $3_prod3.nc
#pmemd.cuda -O -i prod.mdin -o $3_prod4.mdout -p $3_solvated.prmtop -c $3_prod3.rst -r $3_prod4.rst -ref $3_prod3.rst -inf $3_prod4.info -x $3_prod4.nc
EOF

#Make slurm script for running production runs
cat > prod/1/run_prod.slurm << EOF
#!/bin/bash
#SBATCH --job-name=0_0_??
#SBATCH --output=$3_%j.out
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

pmemd.cuda -O -i prod.mdin -o $3_prod1.mdout -p $3_solvated.prmtop -c $3_equil.rst -r $3_prod1.rst -ref $3_equil.rst -inf $3_prod1.info -x $3_prod1.nc
#pmemd.cuda -O -i prod.mdin -o $3_prod2.mdout -p $3_solvated.prmtop -c $3_prod1.rst -r $3_prod2.rst -ref $3_prod1.rst -inf $3_prod2.info -x $3_prod2.nc
#pmemd.cuda -O -i prod.mdin -o $3_prod3.mdout -p $3_solvated.prmtop -c $3_prod2.rst -r $3_prod3.rst -ref $3_prod2.rst -inf $3_prod3.info -x $3_prod3.nc
#pmemd.cuda -O -i prod.mdin -o $3_prod4.mdout -p $3_solvated.prmtop -c $3_prod3.rst -r $3_prod4.rst -ref $3_prod3.rst -inf $3_prod4.info -x $3_prod4.nc
EOF

# Make cpptraj script to align and visualize individual production run (per 250ns)
cat > prod/1/process_prod.cpptraj << EOF
parm $3_solvated.prmtop
trajin $3_prod1.nc 1 last 10

autoimage
rms fit :1-$1@CA

trajout $3_prod_aligned.nc
EOF

