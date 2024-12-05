#!/bin/bash

#Make cleanup file to sort files into directories and also make replica files

#Filetree will look like this:

#input
	#starting pdb files/papers (original PDB)

#parm
	#antechamber files for parametrization
	#tleap files with scripts and solvated systems (prmtop and solvated pdb are here)

#prep
	#min (with files and protocols)
	#heat
	#equil files

#prod


#Make prod files
mkdir prod

mkdir prod/1
mv *prod.* prod/1
cp *prmtop prod/1
cp *_equil.rst prod/1

cp -r prod/1 prod/2
cp -r prod/2 prod/3

mv *_1.slurm prod/1
mv *_2.slurm prod/2
mv *_3.slurm prod/3

#Make prep files
mkdir prep
mkdir prep/min
mv *min* prep/min

mkdir prep/heat
mv *heat* prep/heat

mkdir prep/equil
mv *equil* prep/equil

#Make parm files
mkdir parm
mkdir parm/antechamber
mv *antechamber* parm/antechamber
mv *A* parm/antechamber
mv sqm* parm/antechamber
mv ???.* parm

mkdir parm/tleap
mv *leap* parm/tleap
mv *solvated* parm/tleap

