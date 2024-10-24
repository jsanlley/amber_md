#!/bin/bash

module load amber

. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $1 $2 1 
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $1 $2 2 
. ~/scripts/amber_md/make_md_scripts/5-prod/make_prod.slurm $1 $2 3 

cp prod.mdin prod/1
cp prod.mdin prod/2
cp prod.mdin prod/3
mv *_1.slurm prod/1
mv *_2.slurm prod/2
mv *_3.slurm prod/3


#. run_cleanup.sh
