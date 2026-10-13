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

Notes:
  Jupyter notebooks (RMSD/RMSF, POVME, PCA, MMGBSA and other analysis notebooks) were moved out of this repo
  and now live in ../jupyter-notebooks. They remain available in this repo's git history before commit e14c217.
  Simulation data (trajectories, restarts, topologies, logs) stays on GPFS and is excluded via .gitignore.
