#!/bin/bash
#PBS -A mccammon-hopper-gpu
#PBS -q home-hopper
#PBS -l nodes=1:ppn=4:gpu
#PBS -l walltime=72:00:00
#PBS -N gamd
#PBS -o pbs.out
#PBS -e pbs.err
#PBS -V
#PBS -M h9wei@ucsd.edu
#PBS -m abe

Folder=${PBS_O_WORKDIR}
cd ${Folder}/

echo $CUDA_VISIBLE_DEVICE
export CUDA_HOME=/opt/cuda/current
export LD_LIBRARY_PATH=/opt/cuda/current/lib64:$LD_LIBRARY_PATH

module load amber

cp ${case}* $TMPDIR
cd $TMPDIR

cat > min1.in <<EOF

 &cntrl
 imin=1, maxcyc=10000,
 ntpr=10,
 ntr=1,
 restraint_wt=500.0,
 restraintmask=':1-173',
 /
EOF
#':1-173' is the protein part of my system

$AMBERHOME/bin/pmemd -O -i $PWD/min1.in -p $PWD/${case}.prmtop -c $PWD/${case}.inpcrd -ref $PWD/${case}.inpcrd -o $PWD/min1.out -r $PWD/min1.restrt

cp *out ${Folder}

cat > min2.in <<EOF

 &cntrl
 imin=1, maxcyc=300000,
 ntpr=10,
 /
EOF

$AMBERHOME/bin/pmemd -O -i $PWD/min2.in -p $PWD/${case}.prmtop -c $PWD/min1.restrt -o $PWD/min2.out -r $PWD/min2.restrt

cp *out ${Folder}

cat > heat1.in <<EOF
&cntrl
   imin=0, irest=0, ntx=1,
   ntpr=1000, ntwx=1000, nstlim=350000,
   dt=0.002, ntt=3, tempi=10,
   temp0=310, gamma_ln=1.0, ig=-1,
   ntp=0, ntc=2, ntf=2,
   ntb=1, nmropt=1
 /
 &wt
   TYPE='TEMP0', ISTEP1=1, ISTEP2=350000,
   VALUE1=10.0, VALUE2=310.0,
 /
 &wt TYPE='END' /
EOF

$AMBERHOME/bin/pmemd -O -i $PWD/heat1.in -p $PWD/${case}.prmtop -c $PWD/min2.restrt -o $PWD/heat1.out -r $PWD/heat1.rst

cp *out ${Folder}

cat > heat2.in <<EOF
&cntrl
   imin=0, irest=1, ntx=5,
   ntpr=1000, ntwx=1000, nstlim=1000000,
   dt=0.002, ntt=3, tempi=10,
   temp0=300, gamma_ln=5.0,
   ntp=1, ntc=2, ntf=2,
   ntb=2, taup=2.0
/
EOF

$AMBERHOME/bin/pmemd.cuda -O -i $PWD/heat2.in -p $PWD/${case}.prmtop -c $PWD/heat1.rst -o $PWD/heat2.out -r $PWD/heat2.rst

cp *out ${Folder}

cat > gamd.in <<EOF
&cntrl
   imin=0, irest=1, ntx=5,
   ntpr=1000, ntwx=10000, nstlim=50500000,
   dt=0.002, ntt=3, tempi=300, gamma_ln=5.0,
   temp0=300, iwrap=1, ig=-1,
   ntp=0, ntc=2, ntf=2,
   ntb=1, cut=8.0,
   ntwr=500, ntxo=1, ioutfm=1

   igamd=3, iE=1, irest_gamd=0,
   ntcmd=500000, nteb=25000000, ntave=50000,
   ntcmdprep=100000, ntebprep=400000,
   sigma0P=6.0, sigma0D=6.0,
&end
EOF

$AMBERHOME/bin/pmemd.cuda -O -i $PWD/gamd.in -p $PWD/${case}.prmtop -c $PWD/heat2.rst -o $PWD/gamd.out -x ${case}_gamd.mdcrd

rm *.in

cp *out ${case}_gamd.mdcrd ${Folder}
