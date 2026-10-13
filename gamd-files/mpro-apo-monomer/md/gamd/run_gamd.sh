#!/bin/bash
module load amber

pmemd.cuda -O -i gamd.mdin -o mpro_apo_monomer_gamd.mdout -p ../../mpro_apo_monomer_solvated.prmtop -c ../prod/mpro_apo_monomer_prod1.rst -r mpro_apo_monomer_gamd.rst -ref ../prod/mpro_apo_monomer_prod1.rst -inf mpro_apo_monomer_gamd.info -x mpro_apo_monomer_gamd.nc
