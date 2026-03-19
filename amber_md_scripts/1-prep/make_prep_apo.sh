#!/bin/bash

# # of salts for monomeric system = ~ 52
# # of salts for dimeric system = ~64

name=$1
state=$2

if [ "$state" != "monomer" ]; then
    salt=64
else
    salt=52
fi

#Prepare ligand-bound model
cat > tleap_apo_$state.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB

MPRO = loadpdb ${name}_prepared.pdb
solvateoct MPRO OPCBOX 10 iso

addionsrand MPRO Na+ $salt Cl- $salt           #0.150M salt conc.
addionsrand MPRO Na+ 6

saveoff MPRO ${name}_solvated.lib                     #save off files
saveamberparm MPRO ${name}_solvated.prmtop ${name}_solvated.inpcrd       #save parm
savepdb MPRO ${name}_solvated.pdb                           #save pdb

quit
EOF

#load module
#module load amber

#run tleap
#tleap -f tleap_*

#delete input script and log file
#rm leap.log
#rm tleap_*

echo 'done'
