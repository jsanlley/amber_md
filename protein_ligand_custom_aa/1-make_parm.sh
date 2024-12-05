#!/bin/bash

#ligand=$1 (eg. LIG.pdb)
#protein-ligand complex name=$2 (eg. protein_ligand_name.pdb)
#charge=$3 (charge on ligand)

# Make antechamber and tleap directories
mkdir parm
mkdir parm/antechamber
mkdir parm/tleap

# Make template .mc file
cat > parm/antechamber/$1_capped.mc << EOF
HEAD_NAME N
TAIL_NAME C
MAIN_CHAIN CA

OMIT_NAME C81
OMIT_NAME C82
OMIT_NAME O83
OMIT_NAME H84
OMIT_NAME H85
OMIT_NAME H86

OMIT_NAME N91
OMIT_NAME C92
OMIT_NAME H93
OMIT_NAME H94
OMIT_NAME H95
OMIT_NAME H96

PRE_HEAD_TYPE C
POST_TAIL_TYPE N
CHARGE 0.0
EOF

# RUN_PARM.SH

# Write a script that will run antechamber and parmchk2 to produce the nessary files required by tleap to describe the ligand. Antechamber will calculate the partial charges of the ligand using semi-empirical QM calculations (bcc).
# IMPORTANT: The charge of your ligand may vary and may need to be redefined in the -nc flag of the antechamber command

cat > parm/antechamber/run_parm.sh << EOF
#!/bin/bash

# Run antechamber on capped ligand pdb file
module load amber

# Remove conect records from ligand file
grep -v "CONECT" $1_capped.pdb > $1_capped_clean.pdb
mv $1_capped_clean.pdb $1_capped.pdb

echo 'Running antechamber...'
antechamber -fi pdb -fo ac -i $1_capped.pdb -o $1_capped.ac -at amber -rn $1 -nc $3 -c bcc
wait

# Check for DU atoms in .ac file (must be renamed with appropriate .ac file)
echo 'Checking for DU atoms in .ac file'
grep 'DU' $1_capped.ac

# Command to replace DU atoms with appropriate atom type (if necessary)
# sed 's/DU/N2/g' $1_capped.ac > $1_capped_N2.ac

# Create .prepin file using .mc file
prepgen -i $1_capped.ac -o $1_capped.prepin -m $1_capped.mc -rn $1

# Create .frcmod files (gaff and ff19SB)
parmchk2 -i $1_capped.ac -f ac -o $1_capped_gaff.frcmod
parmchk2 -i $1_capped.ac -f ac -o $1_capped_ff19SB.frcmod -a Y -p $AMBERHOME/dat/leap/parm/parm10.dat

# Copy frcmod and prepin files to tleap directory
cp *frcmod* ../tleap
cp *prepin ../tleap

EOF

# PARM_TLEAP.IN
# This script will generate the neccesary files that describe the ligand topology (.prmtop) and coordinates (.rst7) required by tleap
# NOTE: The files produced for this ligand (.frcmod, .lib) can be reused to build model systems containing this molecule as long as the residue has the same name and number of atoms.

cat > parm/tleap/parm_tleap_customaa.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB

loadamberprep $1_capped.prepin
loadamberparams $1_capped_ff19SB.frcmod
loadamberparams $1_capped_gaff.frcmod


pdb = loadpdb $2.pdb
solvateoct pdb OPCBOX 10 iso

addionsrand pdb Na+ 53 Cl- 53           #0.150M salt conc.
addionsrand pdb Na+ 4

saveoff pdb $2_solvated.lib                     #save off files
saveamberparm pdb $2_solvated.prmtop $2_solvated.inpcrd       #save parm
savepdb pdb $2_solvated.pdb                           #save pdb
EOF

# Define systems
echo "Ligand and charge: " $1 $3
echo "Protein: " $2

# Copy files to parm/antechamber folder
cp $1_capped.pdb parm/antechamber

cp $2.pdb parm/tleap

