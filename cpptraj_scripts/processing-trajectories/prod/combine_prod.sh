#!/bin/bash
# $1 system name (full) mpro_apo_dimer
# $2 monomer vs dimer
# $3 number of replica (1 2 or 3)

if [ $2 = 'monomer' ]

then 
	length=306

elif [ $2 = 'dimer' ] 
then
	length=612
fi
echo $length

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
trajin $1_prod1.nc 1 last 2
trajin $1_prod2.nc 1 last 2
trajin $1_prod3.nc 1 last 2
trajin $1_prod4.nc 1 last 2
autoimage
rms fit :1-$length
strip :WAT,Na+,Cl- nobox parmout $1_dry_5k-at-500ps.prmtop
trajout $1_prod_aligned_dry_$3_5k-at-500ps.nc
EOF


module load amber
#cpptraj -i combine_prod.cpptraj
cpptraj -i combine_prod_dry.cpptraj
wait

cp *.prmtop ../../
cp *aligned_dry* ../../
rm *cpptraj*
