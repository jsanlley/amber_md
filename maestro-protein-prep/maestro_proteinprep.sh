#!/bin/bash

# Tip: run script from folder containing pdb file to be processed
# Goal: process a given pdb using maetro by:
# removing solvent fragments
# adding hydrogens/protonate according to ph=7.4
# mutate catalytic residues 

# Load module
module load schrodinger/2024u1

# Define pdb file name and output pdb file name
FILE_NAME="$1"

# create output file if it doesnt exist already
if [ ! -f "maestro" ]; then
	mkdir "maestro"
	echo "Created output file for $FILE_NAME"
else
	echo "File already exists!"
fi

# Convert pdb file to maestro file
echo "Converting .pdb to .mae"
/software/repo/moleculardynamics/schrodinger/2024u1/utilities/structconvert -ipdb ${FILE_NAME}_wt.pdb -omae maestro/${FILE_NAME}.mae

# Run the protein preparation wizard to prepare protein (wait until its done)
echo "Running ProteinPrep"
/software/repo/moleculardynamics/schrodinger/2024u1/utilities/prepwizard maestro/${FILE_NAME}.mae maestro/${FILE_NAME}_prepared.mae \
-fillsidechains -disulfides -assign_all_residues -rehtreat -max_states 1 -epik_pH 7.4 -epik_pHt 0.0 \
-antibody_cdr_scheme Kabat -samplewater -propka_pH 7.4 -f S-OPLS -rmsd 0.3 -watdist 8 -addOXT \
-JOBNAME maestro_proteinprep -HOST localhost:4

