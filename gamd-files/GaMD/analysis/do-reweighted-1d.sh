#!/bin/sh

if [ $# != 2 ]
 then
  echo "usage example: ./do-rewright-1d.sh H3-H6-R3.50-A6.34-CA.dat gamd-all.log"
  exit
fi

inputdatfile=$1
gamdlog=$2
#dir_codes=~/sh/analysis/amd-2d-reweight
#cp -v ${dir_codes}/reweight-1d.sh ./

#chmod +x reweight-1d.sh

workfolder=`pwd`
echo "directory: $workfolder"
rm -v weights.dat Phi.dat Psi.dat
rm -v weights0.dat Phi0.dat Psi0.dat dist0.dat
nlines_gamd_eq=0
nlines_cmd=0
nlines_header_xvg=0
nlines_all=`wc -l ${gamdlog} |  awk '{print $1}'`
nlines=$(expr $nlines_all - $nlines_gamd_eq)
# nlines=$nlines_reweight
nlines_reweight=$nlines
nlines_gamd=$(expr $nlines_reweight + $nlines_gamd_eq)
nlines_nc=$(expr $nlines_reweight + $nlines_gamd_eq + $nlines_cmd + 1)
nlines_vmd=$(expr $nlines_reweight + $nlines_gamd_eq + $nlines_cmd )
nlines_xvg=$(expr $nlines_reweight + $nlines_gamd_eq + $nlines_cmd + $nlines_header_xvg )
echo "nlines_gamd, nlines_nc, nlines_xvg = $nlines_gamd, $nlines_nc, $nlines_xvg" | tee -a reweight_variable.log

# calculate weights
ncstep=1
tail -n $nlines_reweight ${gamdlog} | awk "NR%$ncstep==0" |  awk '{if($7>=50)print "nan                " $2  "             " ($8+$7);else print ($8+$7)/(0.001987*310)"                " $2  "             " ($8+$7)}' > weights0.dat
tail -n $nlines_reweight ${inputdatfile} | awk "NR%$ncstep==0" | awk '{print $2}' >> Phi0.dat
cp -v Phi0.dat dist0.dat
paste Phi0.dat  weights0.dat dist0.dat > reweight-data.dat
grep -v nan reweight-data.dat | grep -v "e+" > reweight-data-noNaN.dat
awk '{print $1}' reweight-data-noNaN.dat > Phi.dat
awk '{print $2 "             " $3 "             " $4}' reweight-data-noNaN.dat > weights.dat
wc -l Phi.dat weights.dat | tee -a reweight_variable.log

tail -n $nlines ${inputdatfile} | awk '{print $1}' > t.dat
paste t.dat reweight-data.dat | grep -v nan | grep -v "e+" | awk '{print $1 "      " $2}' > ${inputdatfile%.dat}-noNaN-reweight.dat

##to get the xmin and xmax t.dat
xmin=`sort -n -k1 Phi.dat|head -1|awk '{print $1-1.0}'`
xmax=`sort -n -k1 Phi.dat|tail -1|awk '{print $1+1.0}'`
#xmin=-180
#xmax=180
Emax=100.0
#cutoff=500
#xmin=11
#xmax=19

echo "xmin xmax for this file"
for cutoff in 300;do
for binx in 6.0 ; do
./reweight-1d.sh $Emax $cutoff $binx Phi.dat 310.0|tee -a reweight.log
mkdir pmf-${inputdatfile%.dat}-bin$binx-cutoff$cutoff
mv -v pmf-*xvg pmf-${inputdatfile%.dat}-bin$binx-cutoff$cutoff
done # bin
done # cutoff


