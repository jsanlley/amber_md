#!/bin/bash

module load amber

. ~/scripts/amber_md/amber_md_scripts/2-min/make_min_dimer.sh $1 
. ~/scripts/amber_md/amber_md_scripts/3-heat/make_heat_dimer.sh $1
. ~/scripts/amber_md/amber_md_scripts/4-equil/make_equil_dimer.sh $1
. ~/scripts/amber_md/amber_md_scripts/5-prod/make_prod.slurm $1 $3

#tleap -f tleap_$2_dimer.in
. run_min.sh
. run_heat.sh
. run_equil.sh
#. run_prod.slurm
#grep "HID" *solvated.pdb
