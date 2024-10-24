#!/bin/bash
cat > tleap_check_pdb.in << EOF
source leaprc.protein.ff19SB
source leaprc.water.opc
source leaprc.gaff

#loadamberparams $2.frcmod
#loadoff $2.lib

MPRO = loadpdb $1.pdb
check MPRO
EOF

module load amber
tleap -f tleap_check_pdb.in
#rm tleap_check_pdb.in
rm leap.log
rm *sslink*
rm *log*
rm *nonprot*
rm *renum*
