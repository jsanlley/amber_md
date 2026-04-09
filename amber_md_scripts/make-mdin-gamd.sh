#!/bin/bash

# run

if [ -e ./gamd ] ; then
    echo 'file already exists...'
else
    mkdir gamd

    cat > gamd/gamd.mdin <<EOF
    &cntrl
    imin=0,
    ntx=5,
    irest=0,
    ntt=3,
    temp0=310.0,
    tempi=310.0,
    gamma_ln=5.0,
    dt=0.002,
    ntc=2,
    ntf=2,
    ntb=2,
    ntp=1,
    iwrap=1,
    barostat=1,
    cut=10.0,
    nstlim=5050000, ! 10ns total simulation time = ntcmd+nteb
    ntpr=50000, ! 100ps write 1000 frames to mdout and mdinfo files (p.342)
    nscm=1000, ! removal of transaltional and rotational center of mass (p. 344)
    ntwx=50000, ! 100ps write 1000 frames coordinates to nc file (p.342)
    ntwr=50000, ! 100ps write 1000 frames rst file
    
    igamd=3, ! dual boost
    iE=1, ! threshold energy to lower bound
    irest_gamd=0, ! change to 1 for continuing a run 
    ntave=5000, ! 100ps interval steps to calculate simulation statistics (multiple of ntcmdprep, ntcmd, ntebprep, and nteb)
    ntcmd=25000, ! 50ps number of initial conventional molecular dynamics simulation steps
    ntcmdprep=5000, ! 10ns number of preparation conventional molecular dynamics steps. This is used for system equilibration and the potential energies biasing prep MD steps
    nteb=1250000, ! 2.5ns of biasing MD steps
    ntebprep=20000, ! 0.5ns number of preparation biasing molecular dynamics simulation steps
    sigma0P=6.0, ! first potential boost upper limit
    sigma0D=6.0, ! dual potential boost upper limit
   /
EOF


#Make run script to run production from local machine
cat > gamd/run_gamd.sh << EOF
#!/bin/bash
module load amber

pmemd.cuda -O -i gamd.mdin -o $1_gamd.mdout -p ../../$1_solvated.prmtop -c ../prod/$1_prod1.rst -r $1_gamd.rst -ref ../prod/$1_prod1.rst -inf $1_gamd.info -x $1_gamd.nc
EOF
fi
