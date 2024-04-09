#!/bin/bash
cat > tleap_check_pdb.in << EOF
source leaprc.protein.ff19SB
source leaprc.water.opc
source leaprc.gaff

loadamberprep $2.prepin
loadamberparams $2.frcmod2
loadamberparams $2.frcmod1

MPRO = loadpdb $1.pdb
check MPRO
EOF

module load amber
tleap -f tleap_check_pdb.in
rm tleap_check_pdb.in
rm leap.log
