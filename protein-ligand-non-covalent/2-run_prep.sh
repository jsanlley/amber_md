#!/bin/bash

# SOLVATE_TLEAP.IN

# Write a tleap input script that build a protein-complex model within a truncated octahedron shaped explicit solvent within 10A of the protein and enough Na+ and Cl- atoms to match experimental concentrations (0.150M). The protein (ff19SB), water (OPC), and ligand (GAFF) forice field parameters were used to generate the topology (.prmtop) and connectivity (.pdb, .rst7) files.

# IMPORTANT: The charge and size of the solvent box may vary between proteins. For this reason, the Na+ and Cl- ions have been initially set to 0. See README file for details on how to overcome this.

# Define variables from flags
# protein=$1
# ligand=$2

# Navigate to appropriate directory
cd parm/tleap

# Load necessary modules
module load amber

# Run tleap
tleap -f solvate_tleap.in
wait

