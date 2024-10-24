#!/bin/bash

#name = mpro_nrm_capped_gaff_pdb
cat > tleap.in << EOF

source leaprc.protein.ff14SB
source leaprc.gaff

loadamberprep nrm_145_capped_amber_pdb.prepin
loadamberparams nrm_145_capped_amber_pdb.frcmod
loadamberparams nrm_145_capped_amber_pdb_ff14SB.frcmod

MPRO = loadpdb mpro_nirm_144-146.pdb

check

saveoff MPRO mpro_nirm_144-146.lib
saveamberparm MPRO mpro_nirm_144-146.prmtop mpro_nirm_144-146.rst7
quit


EOF

module load amber
tleap -f tleap.in
rm tleap.in
