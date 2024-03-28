#!/bin/bash

# # of salts for monomeric system = ~ 52
# # of salts for dimeric system = ~64

#Prepare ligand-bound model
cat > tleap_$2_monomer.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB


loadamberparams $2.frcmod
loadoff $2.lib

MPRO = loadpdb $1.pdb
solvateoct MPRO TIP3PBOX 10 iso

addionsrand MPRO Na+ 52 Cl- 52           #0.150M salt conc.
addionsrand MPRO Na+ 4

saveoff MPRO $1_solvated.lib                     #save off files
saveamberparm MPRO $1_solvated.prmtop $1_solvated.inpcrd       #save parm
savepdb MPRO $1_solvated.pdb                           #save pdb


quit
EOF

#Prepare ligand-bound model
cat > tleap_$2_dimer.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB


loadamberparams $2.frcmod
loadoff $2.lib

MPRO = loadpdb $1.pdb
solvateoct MPRO TIP3PBOX 10 iso

addionsrand MPRO Na+ 64 Cl- 64           #0.150M salt conc.
addionsrand MPRO Na+ 8

saveoff MPRO $1_solvated.lib                     #save off files
saveamberparm MPRO $1_solvated.prmtop $1_solvated.inpcrd       #save parm
savepdb MPRO $1_solvated.pdb                           #save pdb


quit
EOF

