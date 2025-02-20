#!/bin/bash

# # of salts for monomeric system = ~ 52
# # of salts for dimeric system = ~64

#If parametrizing a small molecule, make script to run antechamber on pdb file of molecule (extracted from final structure)
cat > run_antechamber.sh << EOF
#!/bin/bash

echo 'Running antechamber...'
antechamber -i $2.pdb -fi pdb -o $2.mol2 -fo mol2 -c bcc -s 0
wait

echo 'Running parmchk2...'
parmchk2 -i $2.mol2 -f mol2 -o $2.frcmod
echo 'Done!'
wait

EOF


#Make tleap script to solvate system
#May need to change salt ions to properly solvate system at 0.150mM

#Make ligand parameters
cat > tleap_parm.in << EOF
source leaprc.protein.ff19SB
source leaprc.gaff

loadamberparams $2.frcmod
$2 = loadmol2 $2.mol2
check
saveoff $2 $2.lib
saveamberparm $2 $2.prmtop $2.rst7
quit
EOF

#Prepare ligand-bound model
cat > tleap_$2_monomer.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB


loadamberparams $2.frcmod
loadoff $2.lib

MPRO = loadpdb $1.pdb
solvateoct MPRO TIP3PBOX 10 iso

addionsrand MPRO Na+ 52 Cl- 52           #0.150M salt conc.
addionsrand MPRO Na+ 4

saveoff MPRO $1_solvated.lib                     #save off files
saveamberparm MPRO $1_solvated.prmtop $1_solvated.inpcrd       #save parm
savepdb MPRO $1_solvated.pdb                           #save pdb


quit
EOF

#Prepare ligand-bound model
cat > tleap_$2_dimer.in << EOF
source leaprc.gaff
source leaprc.water.opc
source leaprc.protein.ff19SB


loadamberparams $2.frcmod
loadoff $2.lib

MPRO = loadpdb $1.pdb
solvateoct MPRO TIP3PBOX 10 iso

addionsrand MPRO Na+ 64 Cl- 64           #0.150M salt conc.
addionsrand MPRO Na+ 8

saveoff MPRO $1_solvated.lib                     #save off files
saveamberparm MPRO $1_solvated.prmtop $1_solvated.inpcrd       #save parm
savepdb MPRO $1_solvated.pdb                           #save pdb


quit
EOF
