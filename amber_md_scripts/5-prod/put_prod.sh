#!/bin/bash

#$1 name
#$2 state (monomer / dimer)

prod='./prod/*/*'
ls prod

. ~/scripts/amber_md/make_md_scripts/make_combine_prod_$2.sh
. combine_prod_$2.sh
