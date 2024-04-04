#!/bin/bash

# # of salts for monomeric system = ~ 52
# # of salts for dimeric system = ~64

#Make amber script to run minimization
cat > min1.mdin << EOF  
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

#impose moderate minimization restraints on all non-hydrogen atoms
cat > min2.mdin << EOF
#moderate minimization on protein atoms
&cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=50.0, ! kcal/mol restraint weight (p.344)
  restraintmask=':1-612 & !@H=', ! strong restraint on all non-hydrogen atoms (p.344)
  maxcyc=500, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

#impose moderate minimization restraints on all non-hydrogen atoms
cat > min3.mdin << EOF
#soft minimization on backbone heavy atoms
 &cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=10.0, ! kcal/mol restraint weight (p.344)
  restraintmask=':1-612@CA,N,C,O', ! moderate restraint on all non-hydrogen atoms (p.344)
  maxcyc=500, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

#impose moderate minimization restraints on all non-hydrogen atoms
cat > min4.mdin << EOF
#soft minimization on ligand heavy atoms
 &cntrl
  imin=1, ! flag to run md or minimization (p.340)
  ntx=1,  ! option to read initial coordinates (p.341)
  irest=0 ! flag to restart a simulation anew or from a previous run (p.341)
  ntpr=50, ! write to mdout and mdinfo files (p.342)
  ntr=1, ! flag for applying potential harmonic restraints (for restrained systems) (p.343)
  restraint_wt=10.0, ! kcal/mol restraint weight (p.344)
  restraintmask=':613-614 & !@H=', ! soft restraint on all non-hydrogen atoms (p.344)
  maxcyc=500, ! minimum number of minimizaion cycles (p.344)
  ntmin=1, ! flag for the method of minimization (p.344)
  ncyc=500, ! switching from steepest descent to conjugate gradient (p.344)
/
EOF

#Make amber script to run unrestrained minimization
cat > min5.mdin << EOF
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

#Make run script to run production from local machine
cat > run_min.sh << EOF
#!/bin/bash
module load amber

pmemd.cuda -O -i min1.mdin -o $1_min1.mdout -p $1_solvated.prmtop -c $1_solvated.inpcrd -r $1_min1.rst -ref $1_solvated.inpcrd -inf $1_min1.info
pmemd.cuda -O -i min2.mdin -o $1_min2.mdout -p $1_solvated.prmtop -c $1_min1.rst -r $1_min2.rst -ref $1_min1.rst -inf $1_min2.info 
pmemd.cuda -O -i min3.mdin -o $1_min3.mdout -p $1_solvated.prmtop -c $1_min2.rst -r $1_min3.rst -ref $1_min2.rst -inf $1_min3.info
pmemd.cuda -O -i min4.mdin -o $1_min4.mdout -p $1_solvated.prmtop -c $1_min3.rst -r $1_min4.rst -ref $1_min3.rst -inf $1_min4.info
pmemd.cuda -O -i min5.mdin -o $1_min5.mdout -p $1_solvated.prmtop -c $1_min4.rst -r $1_min5.rst -ref $1_min4.rst -inf $1_min5.info
EOF

