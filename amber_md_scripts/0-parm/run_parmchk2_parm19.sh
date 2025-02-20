#!/bin/bash

module load amber

name="nrm_145_capped_gaff_mol2"

#prepin file as input
parmchk2 -i $name.prepin -f prepi -o $name"_prepin_parm19.frcmod" -a Y -p $AMBERHOME/dat/leap/parm/parm19.dat

#ac file as input
#parmchk2 -i $name.ac -f ac -o $name"_ac_parm19.frcmod" -a Y -p $AMBERHOME/dat/leap/parm/parm19.dat
