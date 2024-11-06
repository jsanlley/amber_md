#!/bin/bash
# $1 system name (full) mpro_apo_dimer
# $2 number of residues in the system (excluding ligand)

length=$2


#make cpptraj script to align and visualize equilibration run
cat > combine_prod.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_prod1.nc 1 last 10
trajin $1_prod2.nc 1 last 10
trajin $1_prod3.nc 1 last 10
trajin $1_prod4.nc 1 last 10
autoimage
rms fit :1-$length
trajout $1_prod_aligned.nc
EOF

cat > combine_prod_dry.cpptraj << EOF
parm $1_solvated.prmtop
trajin $1_prod1.nc 1 last 10
trajin $1_prod2.nc 1 last 10
trajin $1_prod3.nc 1 last 10
trajin $1_prod4.nc 1 last 10
autoimage
rms fit :1-$length
strip :WAT,Na+,Cl- nobox parmout $1_dry.prmtop
trajout $1_prod_aligned_dry_$3.nc
EOF

