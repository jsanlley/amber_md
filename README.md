Protocol for generating MPro trajectories from explicit solvent MD simulations using AMBER22 for the following states:
monomer (bound), dimer (half bound, fully bound)

Divided into the following stages:
parm: 
  Includes scripts to parametrize non-covalent inhibitors as well as covalently bound inhibitors (custom aa)
prep: 
  ff19SB (protein), OPC (water), GAFF (small molecule, if applicable)
  0.150M NaCl based on box volume
  Geenration of topology and coordinate files
prod:
  minimization
  heating
  equilibration
  production




File structure con
