#!/bin/bash

SCRIPTS='/net/gpfs-amarolab/jsanlleyhernandez/scripts'
module load amber

cd 1-min
echo 'Minimizing in {$PWD}...'
. $SCRIPTS/run_min.sh F2459-2036
wait 

cd ../2-heat
echo 'Heating in $PWD....' 
. $SCRIPTS/run_heat.sh F2459-2036
wait

cd ../3-equil
echo 'Equilibrating in $PWD...'
. $SCRIPTS/run_equil.sh F2459-2036
wait

cd ../
echo "Done!"
