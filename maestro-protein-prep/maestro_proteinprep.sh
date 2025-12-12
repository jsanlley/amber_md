#!/bin/bash

# Load module

# Define pdb file name and output pdb file name
FILE_NAME="$1"

# Convert pdb file to maestro file
echo "Convering $1 into .mae file"
mkdir -p pdb/maestro
/software/repo/moleculardynamics/schrodinger/2024u1/utilities/structconvert -ipdb pdb/${FILE_NAME}.pdb -omae pdb/maestro/${FILE_NAME}.mae

# Run the protein preparation wizard to prepare protein (wait until its done)
echo "Running ProteinPrep"
/software/repo/moleculardynamics/schrodinger/2024u1/utilities/prepwizard maestro/${FILE_NAME}.mae maestro/${FILE_NAME}_prepared.mae \
-fillsidechains -assign_all_residues -rehtreat -max_states 1 -epik_pH 7.4 -epik_pHt 0.0 \
-antibody_cdr_scheme Kabat -samplewater -propka_pH 7.4 -f S-OPLS -rmsd 0.3 -watdist 8 -addOXT \
-JOBNAME maestro_proteinprep -HOST localhost:4
