# Summary

# The following scripts are written to produce an explicitly solvated protein-ligand complex for MD simulations using AMBER. 

# More specifically, This script generates the necessary files required to simulate protein-ligand complexes (bound non-covalently) in explicit solvent (all-atom) under physiological conditions (0.150M NaCl, 310K, pH=7.4) using AMBER. 


# Protocol:

# 1. Place your inital protein-ligand complex files in a directory named after your system. Create a separate pdb file containing only the ligand information (no CONECT records). Make sure that the ligand pdb residue name matches the pdb file name, you will use this identifier for the parametrization. E.g. if your ligand name is LIG, then the corresponding pdb file should be LIG.pdb. Have a separate directory titled input with relevant visualizations, papers, structures, etc. Your directory should look like this:

	protein_ligand_state (run scripts from here)
 		- protein.pdb
   		- ligand.pdb
 		- input directory
   			- papers
      			- visualizations
	 		- starting structures
    			- notes
    			- etc.

# 2. Run the 1-run_parm.sh script from the protein-ligand_state directory to obtain necessary files to describe the ligand parameters. Include the ligand name as the first flag (e.g. . run_parm.sh LIG 0) and the charge number for the ligand. This script will create a parm directory containing the antechamber and copy the necessary files to make tleap files. Your directory should now look like this:


	protein_ligand_state
 		- protein.pdb
   		- ligand.pdb
 		- input directory
   			- papers
      			- visualizations
	 		- starting structures
    			- notes
    			- etc.
       		- parm
	 		- antechamber
    			- tleap

# 3. Run the 2-run_prep.sh script from the protein_ligand_state directory to create the solvated model of the protein-ligand complex. This script will write a tleap input script that build a protein-complex model within a truncated octahedron shaped explicit solvent within 10A of the protein and enough Na+ and Cl- atoms to match experimental concentrations (0.150M). The protein (ff19SB), water (OPC), and ligand (GAFF) forice field parameters were used to generate the topology (.prmtop) and connectivity (.pdb, .rst7) files.

# IMPORTANT: The charge and size of the solvent box may vary between proteins. For this reason, the Na+ and Cl- may have to be modified and re-run in order to have the right concentration.

# Parameters:

	# Antechamber:
		# Charge method: bcc
		# Atom type: gaff

	# LeAP
		# For ligand (gaff)
		# For protein (ff19SB)

# 4. Run the 3-make_md.sh script from the protein_ligand_state directory. This script will write the necessary amber input files for all stages of the simulations (minimization, heating, equilibration, and production).

# Before running make sure you include the necessary flags
# $1 length of protein (ex. 306 for mpro)
# $2 ligand residue number
# $3 protein-ligand pdb name (no pdb)

# More information on the option included in the AMBER manual

# Your directory should now look like this:

	protein_ligand_state
 		- protein.pdb
   		- ligand.pdb
 		- input directory
   			- papers
      			- visualizations
	 		- starting structures
    			- notes
    			- etc.
       		- parm
	 		- antechamber
    			- tleap
       		- prep 
			- min
   			- heat
      			- equil
		- prod
  			1 

# 5. cd into the following directories and run the following commands in each:

# 5.1: Minimization
	cd prep/min
 	. run_min.sh

  
# 5.2: Heating
	cd prep/heat
 	. run_heat.sh

  
# 5.3: Equilibration
	cd prep/equil
 	. run_equil.sh

* Note: There are some missing analysis scripts that ideally would generate the appropriate data to assess that each of the steps of the simulation have proceeded accordingly.

# 6. Check that the aforementioned protocols have proceeded with no errors. cd into the prod file and recursively copy the replicas (if doing multiple runs).

cd prod
cp -r 1 2
cp -r 1 3 

# 7. For each of the replicas, the run_prod.sh script will run 250ns of MD. You can extend these simulations by an additional 250ns by commenting out each line with every run. For example, the run_prod.sh script looks like this:

#!/bin/bash
module load amber

pmemd.cuda -O -i prod.mdin -o mpro_fhr_monomer_prod1.mdout -p mpro_fhr_monomer_solvated.prmtop -c mpro_fhr_monomer_equil.rst -r mpro_fhr_monomer_prod1.rst -ref mpro_fhr_monomer_equil.rst -inf mpro_fhr_monomer_prod1.info -x mpro_fhr_monomer_prod1.nc

#pmemd.cuda -O -i prod.mdin -o mpro_fhr_monomer_prod2.mdout -p mpro_fhr_monomer_solvated.prmtop -c mpro_fhr_monomer_prod1.rst -r mpro_fhr_monomer_prod2.rst -ref mpro_fhr_monomer_prod1.rst -inf mpro_fhr_monomer_prod2.info -x mpro_fhr_monomer_prod2.nc

#pmemd.cuda -O -i prod.mdin -o mpro_fhr_monomer_prod3.mdout -p mpro_fhr_monomer_solvated.prmtop -c mpro_fhr_monomer_prod2.rst -r mpro_fhr_monomer_prod3.rst -ref mpro_fhr_monomer_prod2.rst -inf mpro_fhr_monomer_prod3.info -x mpro_fhr_monomer_prod3.nc

#pmemd.cuda -O -i prod.mdin -o mpro_fhr_monomer_prod4.mdout -p mpro_fhr_monomer_solvated.prmtop -c mpro_fhr_monomer_prod3.rst -r mpro_fhr_monomer_prod4.rst -ref mpro_fhr_monomer_prod3.rst -inf mpro_fhr_monomer_prod4.info -x mpro_fhr_monomer_prod4.nc

For the first 250ns, only the first line will be run. In order to continue, comment out the first line and remove the # from the second line (this will begin the second run).

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
 


	


