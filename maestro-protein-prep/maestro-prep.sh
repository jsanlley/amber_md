#!/bin/bash

module load schrodinger/2025u2

input=$1


mkdir maestro

echo "removing ligands"
$SCHRODINGER/run pdbconvert -ipdb  $input.pdb -opdb
$input-clean.pdb -delete_resname DMS,GOL

echo "converting pdb to mae"
$SCHRODINGER/utilities/structconvert $input-clean.pdb maestro/$input.mae

echo "remove dms and gol"
$SCHRODINGER/utilities/prepwizard
