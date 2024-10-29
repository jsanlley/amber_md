# Summary

# The following scripts are written to produce an explicitly solvated protein-ligand complex for MD simulations using AMBER. 

# More specifically, This script generates the necessary files required to simulate protein-ligand complexes (bound non-covalently) in explicit solvent (all-atom) under physiological conditions (0.150M NaCl, 310K, pH=7.4) using AMBER. 


# Protocol:

# Have your prepared (see notes on protein preparation) protein-ligand complex file in a directory. Create a separate pdb file containing only the ligand information (no CONECT records). Make sure that the ligand pdb residue name matches the pdb file name, you will use this identifier for the parametrization. E.g. if your ligand name is LIG, then the corresponding pdb file should be LIG.pdb.

# Run the run_parm.sh script to obtain necessary files to describe the ligand parameters. Include the ligand name as the first flag (e.g. . run_parm.sh LIG 0) and the charge number for the ligand. This script will create a parm directory containing the antechamber and and tleap files.

# Parameters:

	# Antechamber:
		# Charge method: bcc
		# Atom type: gaff

	# LeAP
		# For ligand (gaff)
		# For protein (ff19SB)

# Run the run_prep.sh script to build the solvated system to be used for MD simulations. This script will generate the protein-ligand complex using the previously created parameter files inside a truncated octahedron with a 10Å cutoff from the protein. The number of salt atoms will have to be calculated manually and may vary across systems.


