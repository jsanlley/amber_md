#!/bin/bash
#TEMPERATURE=310
#RC1=Psi.dat
#grep -v "#" ${RC1} >> temp1
#awk '{print $2}' temp1 | tail -n +1 > psi.dat
#paste -d "\t" psi.dat >> Psi
#grep -v "#" gamd-all.log > headerless-gamd.log
#awk 'NR%1==0' headerless-gamd.log |awk -v TEMP=$TEMPERATURE -v IDEAL_GAS_CONSTANT=0.001987 '{print ($8+$7)/(IDEAL_GAS_CONSTANT*TEMP)" " $2 " " ($8+$7)}' > weights.dat
#/shared/apps/software/amber24/miniconda/bin/python3.1 PyReweighting-1D.py -input Psi -T $TEMPERATURE -cutoff 300 -Xdim -180 180 -disc 6 -Emax 100 -job amd_dV -weight weights.dat | tee -a reweight-variable-cumulant-expansion-2D.log
### create by Jinan Wang@UNC Sep-26-2024

if [ $# != 2 ]
 then
  echo "usage example: ./create-1d-anharmonicity.sh Psi_all.dat gamd-all.log"
  exit
fi
RC1=$1
logfile=$2

TEMPERATURE=310

wc -l ${RC1} ${logfile}
awk '{print $2}' ${RC1} | tail -n +1 > psi.dat
paste -d "\t" psi.dat >> Psi

grep -v "#" ~/GaMD/analysis/gamd-all.log > headerless-gamd.log
awk 'NR%1==0' headerless-gamd.log |awk -v TEMP=$TEMPERATURE -v IDEAL_GAS_CONSTANT=0.001987 '{print ($8+$7)/(IDEAL_GAS_CONSTANT*TEMP)" " $2 " " ($8+$7)}' > weights.dat

python3 PyReweighting-1D.py -input Psi -T $TEMPERATURE -cutoff 300 -Xdim -180 180 -disc 6 -Emax 100 -job amd_dV -weight weights.dat | tee -a reweight-variable-cumulant-expansion-1D.log


