#!/bin/bash

#make cpptraj script to align and visualize equilibration run
cat > process_equil.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_equil.nc

autoimage
rms fit :1-306@CA

trajout $1_equil_aligned.nc
trajout $1_equilibrated.pdb pdb onlyframes 50 50 1
EOF

