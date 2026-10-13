#!/bin/sh
antechamber -i CysCNH.pdb -fi pdb -bk CYN -fo ac -o CYN.ac -c bcc -at amber
#change the name DU by N2,
sed 's/DU/N2/g' CYN.ac > CYN_N2.ac

prepgen -i CYN_N2.ac -o CYN.prepin -m CYN.mc -rn CYN
parmchk2 -i CYN_N2.ac -f ac -o CYN_gaff.frcmod
parmchk2 -i CYN_N2.ac -f ac -o CYN_ff14SB.frcmod -a Y -p $AMBERHOME/dat/leap/parm/parm10.dat
