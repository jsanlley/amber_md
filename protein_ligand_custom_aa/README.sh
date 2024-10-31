# Summary

# The following scripts are written to produce an explicitly solvated protein-ligand complex for MD simulations using AMBER. In this case, the ligand is covalently bound to its corresponding catalytic residue. For that reason, additional steps must be taken to account for this "new" amino acid residue representing the ligand in the bound states. 

# More specifically, This script generates the necessary files required to simulate protein-ligand complexes (bound covalently) in explicit solvent (all-atom) under physiological conditions (0.150M NaCl, 310K, pH=7.4) using AMBER. 


# Protocol:

# Have your prepared (see notes on protein preparation) protein-ligand complex file in a directory. Create a separate pdb file containing the ligand-bound residue (no CONECT records). 

# IMPORTANT: Make sure that the residue and ligand name match the pdb file name, you will use this identifier for the parametrization. E.g. if your ligand name is LIG, then the corresponding pdb file should be LIG.pdb. This should also be the case in your model protein-ligand file.

# If your ligand is not bound to the active site residue, model the bond between ligand and reisdue using your modeling software of choice. Make sure that the ligand.pdb file contains the residue and ligand.

# Make a copy of your ligand file and using any molecular modeling software cap the residues with N-Methyl (C-Terminus) and Acetyl (N-Terminus)

# You should also modify the .mc file that will be written with the appropriate ATOM names. This will tell tleap software later on to bind the custom amino acid to its adjacent residues.

# Run the run_parm.sh script to obtain necessary files to describe the ligand parameters. Include the ligand name as the first flag (e.g. . run_parm.sh LIG 0) and the charge number for the ligand. This script will create a parm directory containing the antechamber and and tleap files.

# Parameters:

	# Antechamber:
		# Charge method: bcc
		# Atom type: gaff

	# LeAP
		# For ligand (gaff)
		# For protein (ff19SB)
		# For water (OPC) 

# Simulation specs:

	Periodic boundary conditions for a system within a truncated octahedron geometry.
 	SHAKE algorithm applied to constrain hydrogen bonds when applicable. (cite)
  	2fs timestep between frames.
   	10A cutoff for nonbonded interactions.
    	Target heating temperature to 310K.
     	Salt concentrations adjusted to match experimental concentrations (0.150M NaCl).
      	Constant volume applied for heating simulations (NVT).
       	Constant pressure applied for equilibration and production simulations (NPT). 
   
  	

	1. Minimization
 	2. Heating (250ps + 250ps of restrained and unrestrained runs) = 50 frames/run
  	3. Equilibration (500ps + 500ps of restrained and unrestrained runs) = 100 frames/run (unprocessed)
   	4. Production (250ns) = 2500 frames/run (unprocessed) at a 100ps/frame resolution (unprocessed)

 # Resolution of post-processed trajectories (as defined in cpptraj scritps)

 Equilibration: 100 frames (5ps/frame)
 Production: 250 frames (1ns/frame)
 

# How to use these scripts

	Run the run_prep.sh script to build the solvated system to be used for MD simulations. This script will generate the protein-ligand complex using the previously created parameter files inside a truncated octahedron with a 10Å cutoff from the protein. The number of salt atoms will have to be calculated manually and may vary across systems.


