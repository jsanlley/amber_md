#!/bin/sh
#make sure to modify the path of amber24 to the correct location
#source /shared/apps/software/amber24/amber.sh
which pmemd.cuda
# gamd equilibration
pmemd.cuda -O -i gamd-restart.in -p Ala.parm7 -c gamd-1.rst -o md-2.out -x md-2.nc -r gamd-2.rst -gamd gamd-2.log

