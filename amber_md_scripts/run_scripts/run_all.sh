#!/bin/bash

module load amber

. ~/scripts/amber_md/make_md_scripts/1-prep/make_prep_apo.sh $1
. ~/scripts/amber_md/make_md_scripts/2-min/make_min_$3.sh $1 
. ~/scripts/amber_md/make_md_scripts/3-heat/make_heat_$3.sh $1
. ~/scripts/amber_md/make_md_scripts/4-equil/make_equil_$3.sh $1
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $1 $4 1 
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $1 $4 2
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $1 $4 3




tleap -f tleap_$2_$3.in
wait
. run_min.sh
wait
. run_heat.sh
wait
. run_equil.sh
wait
#. run_cleanup.sh
