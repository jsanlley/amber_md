#!/bin/bash

cd prod/1
. ~/scripts/amber_md/combine_prod.cpptraj $1 $2 1
wait 

cd ../2
. ~/scripts/amber_md/combine_prod.cpptraj $1 $2 2
wait 

cd ../3
. ~/scripts/amber_md/combine_prod.cpptraj $1 $2 3


