#!/bin/bash
### create by Jinan Wang@UNC Sep-26-2024

if [ $# != 3 ]
 then
  echo "usage example: ./create-2d-anharmonicity.sh Phi_all.dat Psi_all.dat gamd-all.log"
  exit
fi

RC1=$1
RC2=$2
logfile=$3

TEMPERATURE=310
cutoff=300
Emax=100
discX=6.0
discY=6.0


rm -v psi.dat phi.dat Phi_Psi
awk '{print $2}' ${RC1} | tail -n +1 > phi.dat
awk '{print $2}' ${RC2} | tail -n +1 > psi.dat
paste -d "\t" phi.dat psi.dat >> Phi_Psi

grep -v "#" ${logfile} > headerless-gamd.log
awk 'NR%1==0' headerless-gamd.log |awk -v TEMP=$TEMPERATURE -v IDEAL_GAS_CONSTANT=0.001987 '{print ($8+$7)/(IDEAL_GAS_CONSTANT*TEMP)" " $2 " " ($8+$7)}' > weights.dat

xmin=`sort -n -k1 phi.dat|head -1|awk '{print $1-1.0}'`
xmax=`sort -n -k1 phi.dat|tail -1|awk '{print $1+1.0}'`
ymin=`sort -n -k1 psi.dat|head -1|awk '{print $1-1.0}'`
ymax=`sort -n -k1 psi.dat|tail -1|awk '{print $1+1.0}'`

echo "python3 PyReweighting-2D.py -input Phi_Psi -T $TEMPERATURE -cutoff ${cutoff} -Xdim $xmin $xmax  -discX ${discX} -Ydim $ymin $ymax  -discY ${discY} -Emax ${Emax} -job amd_dV -weight weights.dat"
python3 PyReweighting-2D.py -input Phi_Psi -T $TEMPERATURE -cutoff ${cutoff} -Xdim $xmin $xmax  -discX ${discX} -Ydim $ymin $ymax  -discY ${discY} -Emax ${Emax} -job amd_dV -weight weights.dat | tee -a reweight-variable-cumulant-expansion-2D.log
#mv -v pmf-c1-Phi_Psi.xvg graphics-out/pmf-Phi_Psi-reweight-CE1.xvg
#mv -v pmf-c2-Phi_Psi.xvg graphics-out/pmf-Phi_Psi-reweight-CE2.xvg
#mv -v pmf-c3-Phi_Psi.xvg graphics-out/pmf-Phi_Psi-reweight-CE3.xvg

#/shared/apps/software/amber24/miniconda/bin/python3.1 PyReweighting-2D.py -input Phi_Psi -T $TEMPERATURE -cutoff ${cutoff} -Xdim $xmin $xmax  -discX ${discX} -Ydim $ymin $ymax  -discY ${discY} -Emax ${Emax} -job noweight -weight graphics/weights.dat | tee -a graphics/noreweight-variable-2D.log
#mv -v pmf-Phi_Psi.xvg graphics-out/pmf-2D-noweight.xvg
#mv -v 2D_Free_energy_surface.png graphics-out/pmf-2D-noweight.png

#mv -v phi.dat psi.dat Phi_Psi graphics/
#mv -v weights-* weights
#mv -v weights.png weights
