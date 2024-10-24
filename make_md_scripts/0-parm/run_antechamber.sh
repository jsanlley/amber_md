#!/bin/bash

# $1 = name of parent ligand (lig)
# $2 = residue identifier (LIG)
# $3 = gaff2 (small molecule force field)
# $4 = input format (pdb)

#example= if your ligand (lig) was parametrized from a pdb file using
#the gaff force field, your output will look like this:
# lig_gaff_pdb.ac
module load amber

name="$1_$3_$4"
format=$4

antechamber -i $1.$format -fi $format -o $name.ac -fo ac -rn $2 -at $3 -c bcc
rm sqm*
rm A*
rm N*

wait

prepgen -i $name.ac -o $name.prepin -m nrm_145.mc -rn $2

wait

parmchk2 -i $name.ac -f ac -o $name.frcmod -a Y -s $3
