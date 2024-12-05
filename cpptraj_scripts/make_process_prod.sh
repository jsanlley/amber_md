#!/bin/bash

# Make cpptraj script to align and visualize individual production run (per 250ns)
cat > process_prod.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_prod1.nc 1 last 10

autoimage
rms fit :1-$2@CA

trajout $1_prod_aligned.nc
EOF

