#!/bin/bash
#Loop through every replica file and run amber
PATH = $PWD

for FILE in $PWD/*
do
	cd $FILE
	module load amber
	

#Create cpptraj_process.in file to run in all replicates
#import and align trajectories
cat > cpptraj_process.in << EOF	 
parm mpro_$1_solvated.prmtop
trajin mpro_$1_prod.nc 1 100
autoimage
trajout mpro_$1_prod_processed.nc cdf
trajout mpro_$1_prod.pdb pdb onlyframes 1
go
EOF

	echo Running cpptraj on $PWD
	cpptraj -i cpptraj_process.in
	wait
	rm cpptraj_process.in
done


