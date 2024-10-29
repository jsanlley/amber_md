#!/bin/bash

#Run this script with the appropriate flags to define the ligand name ($1) and charge ($2)

ligand=$1
charge=$2

# Make antechamber and tleap directories
mkdir parm
mkdir parm/antechamber
mkdir parm/tleap

# RUN_PARM.SH

# Write a script that will run antechamber and parmchk2 to produce the nessary files required by tleap to describe the ligand. Antechamber will calculate the partial charges of the ligand using semi-empirical QM calculations (bcc). 
#IMPORTANT: The charge of your ligand may vary and may need to be redefined in the -nc flag of the antechamber command

cat > parm/antechamber/run_parm.sh << EOF
#!/bin/bash

echo 'Running antechamber...'
antechamber -i $ligand.pdb -fi pdb -o $ligand.mol2 -fo mol2 -c bcc -s 0 -nc $charge -rn $ligand -at gaff
wait

echo 'Running parmchk2...'
parmchk2 -i $ligand.mol2 -f mol2 -o $ligand.frcmod
echo 'Done!'
wait

EOF

# PARM_TLEAP.IN

# This script will generate the neccesary files that describe the ligand topology (.prmtop) and coordinates (.rst7) required by tleap

#NOTE: The files produced for this ligand (.frcmod, .lib) can be reused to build model systems containing this molecule as long as the residue has the same name and number of atoms.

cat > parm/tleap/parm_tleap.in << EOF
source leaprc.protein.ff19SB
source leaprc.gaff

loadamberparams $ligand.frcmod
$ligand = loadmol2 $ligand.mol2
check
saveoff $ligand $ligand.lib
saveamberparm $ligand $ligand.prmtop $ligand.inpcrd
quit

EOF

#Copy input files to antechamber directory

echo "Ligand: " $ligand

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
