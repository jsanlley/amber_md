#!/bin/sh

if [ $# != 3 ]
 then
  echo "usage example: ./do-rewright-1d.sh H3-H6-R3.50-A6.34-CA.dat E172-H264-CA.dat gamd-all.log"
  exit
fi

inputdatfile=$1
inputdatfile2=$2
gamdlog=$3

#dir_codes=~/sh/analysis/amd-2d-reweight
#cp -v ${dir_codes}/reweight-2d.sh ./
chmod +x reweight-2d.sh

workfolder=`pwd`
echo "directory: $workfolder"
rm -v weights.dat Phi.dat Psi.dat
rm -v weights0.dat Phi0.dat Psi0.dat dist0.dat
nlines_gamd_eq=0
nlines_cmd=0
nlines_header_xvg=0
nlines_all=`wc -l ${gamdlog} |  awk '{print $1}'`
nlines=$(expr $nlines_all - $nlines_gamd_eq)
nlines_reweight=$nlines
nlines_gamd=$(expr $nlines_reweight + $nlines_gamd_eq)
nlines_nc=$(expr $nlines_reweight + $nlines_gamd_eq + $nlines_cmd + 1)
nlines_vmd=$(expr $nlines_reweight + $nlines_gamd_eq + $nlines_cmd )
nlines_xvg=$(expr $nlines_reweight + $nlines_gamd_eq + $nlines_cmd + $nlines_header_xvg )
echo "nlines_gamd, nlines_nc, nlines_xvg = $nlines_gamd, $nlines_nc, $nlines_xvg" | tee -a reweight_variable.log

# calculate weights
ncstep=1
tail -n $nlines_reweight ${gamdlog} | awk "NR%$ncstep==0" | awk '{if($7>=60)print "nan                " $2  "             " ($8+$7);else print ($8+$7)/(0.001987*310)"                " $2  "             " ($8+$7)}' > weights0.dat

tail -n $nlines_reweight ${inputdatfile} | awk "NR%$ncstep==0" | awk '{print $2}' >> Phi0.dat
tail -n $nlines_reweight ${inputdatfile2} | awk "NR%$ncstep==0" | awk '{print $2}' >> Psi0.dat
cp -v Phi0.dat dist0.dat
wc -l Phi0.dat Psi0.dat weights0.dat dist0.dat | tee -a reweight_variable.log
paste Phi0.dat Psi0.dat weights0.dat dist0.dat > reweight-data.dat
grep -v nan reweight-data.dat | grep -v "e+" > reweight-data-noNaN.dat
awk '{print $1}' reweight-data-noNaN.dat > Phi.dat
awk '{print $2}' reweight-data-noNaN.dat > Psi.dat
awk '{print $3 "             " $4 "             " $5}' reweight-data-noNaN.dat > weights.dat
paste Phi.dat Psi.dat > Phi_Psi
wc -l Phi.dat Phi_Psi weights.dat | tee -a reweight_variable.log

#head -n $nlines ${inputdatfile} | awk '{print $1}' > t.dat
tail -n $nlines ${inputdatfile} | awk '{print $1}' > t.dat
paste t.dat reweight-data.dat | grep -v nan | grep -v "e+" | awk '{print $1 "      " $2}' > ${inputdatfile%.dat}-noNaN-reweight.dat

Emax=100.0
for cutoff in 300;do
for binx in 6.0 ; do
for biny in 6.0 ; do
./reweight-2d.sh $Emax $cutoff $binx $biny Phi_Psi 310.0
mkdir pmf-2d-binx$binx-biny$biny-cutoff$cutoff
mv -v pmf-2D-*xvg pmf-2D-*png pmf-2d-binx$binx-biny$biny-cutoff$cutoff
cp  pmf-2d-binx$binx-biny$biny-cutoff$cutoff/pmf-2D-c2-Phi_Psi-reweight-discx${binx}-discy${biny}.xvg results/pmf-2D-c2-Emax-${Emax}-binx$binx-biny$biny-cutoff$cutoff.xvg
done #binx
done # biny
done #cutoff


