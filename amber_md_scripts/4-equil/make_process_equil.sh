#!/bin/bash

# 1 pdb name
# 2 heat/equil


#make cpptraj script to align and visualize equilibration run
cat > analyze-traj.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_equil.nc

autoimage
rms fit :1-306@CA

trajout $1_equil_aligned.nc
trajout $1_equilibrated.pdb pdb onlyframes 50 50 1
EOF

