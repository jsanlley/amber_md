#!/bin/bash
#path = 'net/gpfs-amarolab/jsanlleyhernandez/mpro_md/mpro_apo/mpro_apo_dimer/prod/1/'

# $1 = flag for pdb name 

#make script
cat > get_dry_pdb_from_equil.cpptraj << EOF
parm ../../parm/tleap/$1_solvated.prmtop 				#load topology
trajin $1_equil.nc 1 1 	#load trajectory, change  <start> last <offset>
autoimage				#align
strip :WAT,Cl-,Na+			#dry (optional)
trajout $1_equil_dry.pdb pdb 			#output dry pdb from sliced traj
EOF
