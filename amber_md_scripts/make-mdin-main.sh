# creates directories and appropriate input files
# check restraint mask on heating and ligand (may need to be changed)

# call prmtop and inpcrd files from pdb, then call the rest from the respective directory
# add solvated and equilibrated structures to pdb directory (so theyre all in the same place)

# define state (monomer,dimer,dimer_asym) to define variables for .mdin files
state=$1
if [ $state == 'monomer' ]; then
    restraint=':1-306'
    ligand=':307-317' # double check that the peptides are in fact 10
elif [ $state == 'dimer_asym' ]; then
    restraint=':1-612'
    ligand=':613-623'
else
    restraint=':1-612'
    ligand=':613-633'
fi
echo $state $restraint $ligand

# MINIMIZATION
if [ -e ./min ] ; then
    echo 'file already exists...'
else
    mkdir min

    #impose strong minimization restraints on all non-hydrogen atoms
    cat > min/min1.mdin << EOF  
    #strong minimization on non hydrogen atoms
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

    #impose moderate minimization restraints on all non-hydrogen atoms
    cat > min/min2.mdin << EOF
    #moderate minimization on protein atoms
    &cntrl
    imin=1, ! flag to run md or minimization (p.340)
    ntx=1,  ! option to read initial coordinates (p.341)
    irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
    ntpr=50, ! write to mdout and mdinfo files (p.342)
    ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
    restraint_wt=50.0, ! kcal/mol restraint weight (p.344)
    restraintmask='$restraint & !@H=', ! strong restraint on all non-hydrogen atoms (p.344)
    maxcyc=500, ! minimum number of minimizaion cycles (p.344)
    ntmin=1, ! flag for the method of minimization (p.344)
    ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
    /
EOF

    #impose soft minimization restraints on all non-hydrogen atoms
    cat > min/min3.mdin << EOF
    #soft minimization on backbone heavy atoms
    &cntrl
    imin=1, ! flag to run md or minimization (p.340)
    ntx=1,  ! option to read initial coordinates (p.341)
    irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
    ntpr=50, ! write to mdout and mdinfo files (p.342)
    ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
    restraint_wt=10.0, ! kcal/mol restraint weight (p.344)
    restraintmask='$restraint@CA,N,C,O', ! moderate restraint on all non-hydrogen atoms (p.344)
    maxcyc=500, ! minimum number of minimizaion cycles (p.344)
    ntmin=1, ! flag for the method of minimization (p.344)
    ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
    /
EOF

    #impose moderate minimization restraints on all ligand non-hydrogen atoms
    cat > min/min4.mdin << EOF
    #soft minimization on ligand heavy atoms
    &cntrl
    imin=1, ! flag to run md or minimization (p.340)
    ntx=1,  ! option to read initial coordinates (p.341)
    irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
    ntpr=50, ! write to mdout and mdinfo files (p.342)
    ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
    restraint_wt=10.0, ! kcal/mol restraint weight (p.344)
    restraintmask='$ligand & !@H=', ! soft restraint on all non-hydrogen atoms (p.344)
    maxcyc=500, ! minimum number of minimizaion cycles (p.344)
    ntmin=1, ! flag for the method of minimization (p.344)
    ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
    /
EOF

    #run unrestrained minimization
    cat > min/min5.mdin << EOF
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

    #make script to run minimization
    cat > min/run_min.sh << EOF
    #!/bin/bash
    module load amber

    pmemd.cuda -O -i min1.mdin -o $1_min1.mdout -p $1_solvated.prmtop -c $1_solvated.inpcrd -r $1_min1.rst -ref $1_solvated.inpcrd -inf $1_min1.info
    pmemd.cuda -O -i min2.mdin -o $1_min2.mdout -p $1_solvated.prmtop -c $1_min1.rst -r $1_min2.rst -ref $1_min1.rst -inf $1_min2.info 
    pmemd.cuda -O -i min3.mdin -o $1_min3.mdout -p $1_solvated.prmtop -c $1_min2.rst -r $1_min3.rst -ref $1_min2.rst -inf $1_min3.info
    pmemd.cuda -O -i min4.mdin -o $1_min4.mdout -p $1_solvated.prmtop -c $1_min3.rst -r $1_min4.rst -ref $1_min3.rst -inf $1_min4.info
    pmemd.cuda -O -i min5.mdin -o $1_min5.mdout -p $1_solvated.prmtop -c $1_min4.rst -r $1_min5.rst -ref $1_min4.rst -inf $1_min5.info
EOF
fi


# HEATING
if [ -e ./heat ] ; then
    echo 'file already exists...'
else
#Make amber script to run minimization
    mkdir heat

    cat > heat/rheat.mdin << EOF
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
    restraintmask='$restraint & $ligand', ! specifies restrained atoms in system (p.344)
    /
EOF

    #Make amber script to run unrestrained heating 250ps
    cat > heat/heat.mdin << EOF
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

    #Make run script to run from local machine
    cat > heat/run_heat.sh << EOF
    #!/bin/bash
    module load amber

    echo 'Running rheat'
    pmemd.cuda -O -i rheat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_min5.rst -r $1_rheat.rst -ref $1_min5.rst -inf $1_rheat.info -x $1_rheat.nc

    echo 'Running heat'
    pmemd.cuda -O -i heat.mdin -o $1_heat.mdout -p $1_solvated.prmtop -c $1_rheat.rst -r $1_heat.rst -ref $1_rheat.rst -inf $1_heat.info -x $1_heat.nc
EOF

fi

# EQUILIBRATION
if [ -e ./equil ] ; then
    echo 'file already exists...'
else
#Make amber script to run minimization
    mkdir equil

    cat > equil/requil.mdin << EOF
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
    restraintmask='$restraint & $ligand', ! specifies restrained atoms in system (p.344)
    /
EOF

    #Make amber script to run restrained equilibration 250ps
    cat > equil/equil.mdin << EOF
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

    # Run equilibration script
    cat > equil/run_equil.sh << EOF
    #!/bin/bash
    module load amber

    echo 'Running requil'
    pmemd.cuda -O -i requil.mdin -o $1_requil.mdout -p $1_solvated.prmtop -c $1_heat.rst -r $1_requil.rst -ref $1_heat.rst -inf $1_requil.info -x $1_requil.nc

    echo 'Running equil'
    pmemd.cuda -O -i equil.mdin -o $1_equil.mdout -p $1_solvated.prmtop -c $1_requil.rst -r $1_equil.rst -ref $1_requil.rst -inf $1_equil.info -x $1_equil.nc
EOF
fi

# PRODUCTION    
if [ -e ./prod ] ; then
    echo 'file already exists...'
else
    #Make amber script to run production
    mkdir -p prod/1

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
    ntpr=50000, ! 250ps write 2500 frames to mdout and mdinfo files (p.342)
    nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
    ntwx=50000, ! 250ps write 2500 frames coordinates to nc file (p.342)
    ntwr=50000, ! 250ps write 2500 frames rst file
    /
EOF

    #Make run script to run production from local machine
    cat > prod/1/run_prod.sh << EOF
    #!/bin/bash
    module load amber

    pmemd.cuda -O -i prod.mdin -o $1_prod1.mdout -p $1_solvated.prmtop -c $1_equil.rst -r $1_prod1.rst -ref $1_equil.rst -inf $1_prod1.info -x $1_prod1.nc
    #pmemd.cuda -O -i prod.mdin -o $1_prod2.mdout -p $1_solvated.prmtop -c $1_prod1.rst -r $1_prod2.rst -ref $1_prod1.rst -inf $1_prod2.info -x $1_prod2.nc
    #pmemd.cuda -O -i prod.mdin -o $1_prod3.mdout -p $1_solvated.prmtop -c $1_prod2.rst -r $1_prod3.rst -ref $1_prod2.rst -inf $1_prod3.info -x $1_prod3.nc
    #pmemd.cuda -O -i prod.mdin -o $1_prod4.mdout -p $1_solvated.prmtop -c $1_prod3.rst -r $1_prod4.rst -ref $1_prod3.rst -inf $1_prod4.info -x $1_prod4.nc
EOF

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
fi

