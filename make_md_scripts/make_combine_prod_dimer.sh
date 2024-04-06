#!/bin/bash

#make cpptraj script to align and visualize equilibration run
cat > combine_prod_dimer.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_prod1.nc 1 last 10
#trajin $1_prod2.nc 1 last 10
#trajin $1_prod3.nc 1 last 10
#trajin $1_prod4.nc 1 last 10
autoimage
rms fit :1-612
trajout $1_prod_aligned_$2.nc
EOF
