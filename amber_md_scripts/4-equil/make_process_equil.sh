#!/bin/bash

# 1 pdb name
# 2 heat/equil

restraint=$2

#make cpptraj script to align and visualize equilibration run
cat > process_equil.cpptraj << EOF
    parm ../../$1_solvated.prmtop
    trajin $1_equil.nc

    autoimage
    rms fit :1-$restraint@CA

    trajout $1_equil_aligned.nc
    trajout $1_equilibrated.pdb pdb onlyframes 50 50 1
EOF

