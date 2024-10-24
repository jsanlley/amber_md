#!/bin/bash

# $1 name of system (mpro_ens_monomer)
# $2 state of system (apo,monomer,dimer)
# $3 old slurm name (am_1_1)
# $4 new slurm name (am_1_2)

syspath=$PWD

#for a give system define the state (monomer, dimer, dimer_asym)
#go into each of the replica files
#run the combine_prod.cpptraj script to create dry trajectories to check up to 500ns dry

for replica in 1 2 3
do
	cd $syspath/$1/prod/$replica
	
	pwd
	
	. ~/scripts/amber_md/cpptraj_scripts/calc_rmsf_all.cpptraj $1 $2 $replica

done

cd $syspath
#iterate over each of the production runs

#head the slurm file of each production

#go back to the system path
