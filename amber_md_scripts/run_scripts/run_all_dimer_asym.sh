#!/bin/bash

module load amber

. ~/scripts/amber_md/make_md_scripts/1-prep/make_prep_dimer.sh $1 $2
. ~/scripts/amber_md/make_md_scripts/2-min/make_min_dimer_asym.sh $1 
. ~/scripts/amber_md/make_md_scripts/3-heat/make_heat_dimer_asym.sh $1
. ~/scripts/amber_md/make_md_scripts/4-equil/make_equil_dimer_asym.sh $1

tleap -f tleap_$2_dimer.in
. run_min.sh
. run_heat.sh
. run_equil.sh
grep "HID" *solvated.pdb
