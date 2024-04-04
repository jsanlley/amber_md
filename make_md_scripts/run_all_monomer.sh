#!/bin/bash

module load amber

path ='~/scripts/amber_md/make_md_scripts'
. ~/scripts/amber_md/make_md_scripts/1-prep/make_prep_$3.sh $1 $2
. ~/scripts/amber_md/make_md_scripts/2-min/make_min_$3.sh $1 
. ~/scripts/amber_md/make_md_scripts/3-heat/make_heat_$3.sh $1
. ~/scripts/amber_md/make_md_scripts/4-equil/make_equil_$3.sh $1
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $4 1 1
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $4 1 2 
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $4 1 3
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $4 1 4 




tleap -f tleap_$2_dimer.in
. run_min.sh
. run_heat.sh
. run_equil.sh
#. run_cleanup.sh
#. copy_prod.sh
