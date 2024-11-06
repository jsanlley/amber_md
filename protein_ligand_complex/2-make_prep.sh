#!/bin/bash

# SOLVATE_TLEAP.IN

# Write a tleap input script that build a protein-complex model within a truncated octahedron shaped explicit solvent within 10A of the protein and enough Na+ and Cl- atoms to match experimental concentrations (0.150M). The protein (ff19SB), water (OPC), and ligand (GAFF) forice field parameters were used to generate the topology (.prmtop) and connectivity (.pdb, .rst7) files.

# IMPORTANT: The charge and size of the solvent box may vary between proteins. For this reason, the Na+ and Cl- ions have been initially set to 0. See README file for details on how to overcome this.

# Define variables from flags
# protein=$1
# ligand=$2


# Copy protein file to tleap directory
cp $1.pdb parm/tleap

cat > parm/tleap/solvate_tleap.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB


loadamberparams $2.frcmod
loadoff $2.lib

pdb = loadpdb $1.pdb
solvateoct pdb OPCBOX 10 iso

addionsrand pdb Na+ 53 Cl- 53           #0.150M salt conc.
addionsrand pdb Na+ 4

saveoff pdb $1_solvated.lib                     #save off files
saveamberparm pdb $1_solvated.prmtop $1_solvated.inpcrd       #save parm
savepdb pdb $1_solvated.pdb                           #save pdb

check pdb
quit
EOF

