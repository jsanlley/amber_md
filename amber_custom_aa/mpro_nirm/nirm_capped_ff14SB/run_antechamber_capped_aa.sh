#!/bin/bash

module load amber

antechamber -fi pdb -fo ac -i nirm_capped.pdb -o nirm_capped.ac -at amber -rn 4WI -nc 0 -c bcc

#change the name DU by N2,
sed 's/DU/N2/g' nirm_capped.ac > nirm_capped_N2.ac

prepgen -i nirm_capped_N2.ac -o nirm_capped.prepin -m nirm_capped.mc -rn 4WI

parmchk2 -i nirm_capped_N2.ac -f ac -o nirm_capped_gaff.frcmod
parmchk2 -i nirm_capped_N2.ac -f ac -o nirm_capped_ff14SB.frcmod -a Y -p $AMBERHOME/dat/leap/parm/parm10.dat

