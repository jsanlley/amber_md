#!/bin/bash

name=$1

cat > tleap.in << EOF
source leaprc.protein.ff19SB
source leaprc.water.opc

pdb = loadpdb ${name}_prepared.pdb
solvateoct pdb OPCBOX 10 iso
check pdb
quit
EOF

tleap -f tleap.in
wait

grep "A^3" leap.log
grep "FATAL" leap.log
grep "charge" leap.log
rm tleap.in
rm leap.log
