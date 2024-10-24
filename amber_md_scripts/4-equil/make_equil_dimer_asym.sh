#!/bin/bash
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
  restraintmask=':1-613', ! specifies restrained atoms in system (p.344)
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

#make cpptraj script to align and visualize equilibration run
cat > combine_equil.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_equil.nc
autoimage
rms fit :1-612@CA
trajout $1_equil_aligned.nc
trajout $1_equil.pdb pdb onlyframes 50 50 1
EOF

#Make run script to run from local machine
cat > run_equil.sh << EOF
#!/bin/bash
module load amber

echo 'Running requil'
pmemd.cuda -O -i requil.mdin -o $1_requil.mdout -p $1_solvated.prmtop -c $1_heat.rst -r $1_requil.rst -ref $1_heat.rst -inf $1_requil.info -x $1_requil.nc

echo 'Running equil'
pmemd.cuda -O -i equil.mdin -o $1_equil.mdout -p $1_solvated.prmtop -c $1_requil.rst -r $1_equil.rst -ref $1_requil.rst -inf $1_equil.info -x $1_equil.nc

cpptraj -i combine_equil.cpptraj
EOF
