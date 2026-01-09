#!/bin/bash

SYSPATH='/net/gpfs-amarolab/jsanlleyhernandez/mpro_md/mpro_'$1'/3*/4*/'
cd $SYSPATH
cat > cpptraj.in << EOF
parm 1/mpro_$1_solvated.prmtop
trajin 1/mpro_$1_prod_processed.nc 1 100
trajin 2/mpro_$1_prod_processed.nc 1 100
trajin 3/mpro_$1_prod_processed.nc 1 100
strip :Na+,Cl-
cluster c1 \
 kmeans clusters 10 randompoint maxit 500 \
 rms :611 \
 sieve 10 random \
 out ../../4-analysis/mpro_$1_$2_kmeans_cnumvtime.dat \
 summary ../../4-analysis/mpro_$1_$2_kmeans_summary.dat \
 info ../../4-analysis/mpro_$1_$2_kmeans_info.dat \
 cpopvtime ../../4-analysis/mpro_$1_$2_kmeans_cpopvtime.agr normframe \
 repout ../../4-analysis/mpro_$1_$2_kmeans_rep repfmt pdb \
 singlerepout ../../4-analysis/mpro_$1_$2_kmeans_singlerep.nc singlerepfmt netcdf \
 avgout ../../4_analysis/mpro_$1_$2_kmeans_avg avgfmt pdb
run
EOF


	module load amber
	cpptraj -i cpptraj.in
	wait
	echo 'Done'
	rm cpptraj.ini
	gpfs
