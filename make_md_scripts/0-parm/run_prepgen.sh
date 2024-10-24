#!/bin/bash

module load amber

name="nrm_145_capped_gaff_mol2"
format=$4

prepgen -i $name.ac -o $name.prepin -m nrm_145.mc -rn NRM

