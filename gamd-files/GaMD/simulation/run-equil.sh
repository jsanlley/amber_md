#!/bin/sh
#make sure to modify the path of amber24 to the correct location
#source /shared/apps/software/amber24/amber.sh
which pmemd.cuda
# gamd equilibration
pmemd.cuda -O -i md.in -p Ala.parm7 -c cmd.rst7 -o md-1.out -x md-1.nc -r gamd-1.rst -gamd gamd-1.log

