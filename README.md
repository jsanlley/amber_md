#Amber_MD
#AMBER scripts for running MD
#Takes in PDB as input can be apo or co-crystallized
#Co-Crystallizes PDBs require additional paramterization


# 1: Prepare PDB File for solvation
# Make sure all loops have been modeled
# Submit structure for AMBER-friendly calculations of titratable sites (protonation states)
#Extract ligand from prepared pdb file using pdbtools (pdb_selres 7YY input.pdb > output.pdb
