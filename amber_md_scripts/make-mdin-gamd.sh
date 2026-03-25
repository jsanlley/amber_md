#!/bin/bash

if [ -e ./min ] ; then
    echo 'file already exists...'
else
    mkdir min
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
fi
