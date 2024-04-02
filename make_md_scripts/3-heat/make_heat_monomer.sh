#!/bin/bash

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
  restraintmask=':1-306', ! specifies restrained atoms in system (p.344)
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

#Make run script to run from local machine
cat > run_heat.sh << EOF
#!/bin/bash
module load amber

echo 'Running rheat'
pmemd.cuda -O -i rheat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_min5.rst -r $1_rheat.rst -ref $1_min5.rst -inf $1_rheat.info -x $1_rheat.nc

echo 'Running heat'
pmemd.cuda -O -i heat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_rheat.rst -r $1_heat.rst -ref $1_rheat.rst -inf $1_heat.info -x $1_heat.nc
EOF
