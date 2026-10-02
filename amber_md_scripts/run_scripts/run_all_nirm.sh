#!/bin/bash

script='/home/jsanlleyhernandez/scripts/amber_md/make_md_scripts'
nirm='/net/gpfs-amarolab/jsanlleyhernandez/mpro_md/mpro_nirm'
nirm_monomer="mpro_nirm_monomer"
nirm_dimer="mpro_nirm_dimer"
nirm_dimer_asym="mpro_nirm_dimer_asym"
ligand="nrm_145"

cd "$nirm"/"$nirm_monomer"
echo "$nirm"/"$nirm_monomer"
. ~/scripts/amber_md/make_md_scripts/1-prep/make_prep_customaa_monomer.sh $nirm_monomer $ligand
. ~/scripts/amber_md/make_md_scripts/2-min/make_min_monomer.sh $nirm_monomer
. ~/scripts/amber_md/make_md_scripts/3-heat/make_heat_monomer.sh $nirm_monomer
. ~/scripts/amber_md/make_md_scripts/4-equil/make_equil_monomer.sh $nirm_monomer

tleap -f tleap_nrm_145_monomer.in
. run_min.sh
. run_heat.sh
. run_equil.sh



cd "$nirm"/"$nirm_dimer"
echo "$nirm"/"$nirm_dimer"
. ~/scripts/amber_md/make_md_scripts/1-prep/make_prep_customaa_dimer.sh $nirm_dimer $ligand
. ~/scripts/amber_md/make_md_scripts/2-min/make_min_dimer.sh $nirm_dimer
. ~/scripts/amber_md/make_md_scripts/3-heat/make_heat_dimer.sh $nirm_dimer
. ~/scripts/amber_md/make_md_scripts/4-equil/make_equil_dimer.sh $nirm_dimer

tleap -f tleap_nrm_145_dimer.in
. run_min.sh
. run_heat.sh
. run_equil.sh



cd "$nirm"/"$nirm_dimer_asym"
echo "$nirm"/"$nirm_dimer_asym"
. ~/scripts/amber_md/make_md_scripts/1-prep/make_prep_customaa_dimer.sh $nirm_dimer_asym $ligand
. ~/scripts/amber_md/make_md_scripts/2-min/make_min_dimer_asym.sh $nirm_dimer_asym
. ~/scripts/amber_md/make_md_scripts/3-heat/make_heat_dimer_asym.sh $nirm_dimer_asym
. ~/scripts/amber_md/make_md_scripts/4-equil/make_equil_dimer_asym.sh $nirm_dimer_asym

tleap -f tleap_nrm_145_dimer.in
. run_min.sh
. run_heat.sh
. run_equil.sh
cd $nirm
