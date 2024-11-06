#!/bin/bash

#Run this script with the appropriate flags to define the ligand name ($1) and charge ($2)

ligand=$1
charge=$2

echo "Ligand: " $ligand
echo "Charge: " $charge

# Load amber

module load amber

# Run antechamber
cp $ligand.pdb parm/antechamber
cd parm/antechamber
echo "Running parametrization with antechamber"
. run_parm.sh
wait

# Run tleap script
cp *.frcmod ../tleap
cp *.mol2 ../tleap
echo "Preparing ligand topology files"
tleap -f parm_tleap.in
wait

cd ../../
