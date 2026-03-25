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

add_bonds=""
if [ "$state" == "monomer" ]; then
    add_bonds=$(cat <<'MONO'
#bond MPRO.307.C MPRO.308.N
#bond MPRO.318.C MPRO.319.N
MONO
)
elif [ "$state" == "dimer_asym" ]; then
    add_bonds=$(cat <<'DIMER_ASYM'
#bond MPRO.613.C MPRO.614.N
#bond MPRO.624.C MPRO.625.N   
DIMER_ASYM
)
elif [ "$state" == "dimer" ]; then
    add_bonds=$(cat <<'DIMER'
#bond MPRO.613.C MPRO.614.N
#bond MPRO.624.C MPRO.625.N   
#bond MPRO.637.C MPRO.638.N
#bond MPRO.626.C MPRO.627.N   
DIMER
)
fi

#Prepare ligand-bound model
cat > tleap_${name}_${state}.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB

# remove conect records from pdb
# reorganize caps in the right order
# rename cap atoms if necessary
MPRO = loadpdb ${name}_prepared.pdb
solvateoct MPRO OPCBOX 10 iso

addionsrand MPRO Na+ $salt Cl- $salt           #0.150M salt conc.
addionsrand MPRO Na+ 6

# use if peptide substrate caps are not connected (not necessary but good to have)
$add_bonds

saveoff MPRO ${name}_solvated.lib                     #save off files
saveamberparm MPRO ${name}_solvated.prmtop ${name}_solvated.inpcrd       #save parm
savepdb MPRO ${name}_solvated.pdb                           #save pdb

quit
EOF

echo 'done'
