#!/bin/bash

SYSTEM="/net/gpfs-amarolab/amsrivastava/Helicase/5ROB_simulation_30Aug/production"
OUTPUT="/net/gpfs-amarolab/jsanlleyhernandez/for_ambuj/cluster_out"
cat > cpptraj.in << EOF
parm $SYSTEM/Apo_sol_ion.prmtop
trajin $SYSTEM/prod1-100ns.crd 1 last 10
trajin $SYSTEM/prod101-200ns.crd 1 last 10
trajin $SYSTEM/prod201-300ns.crd 1 last 10
trajin $SYSTEM/prod301-400ns.crd 1 last 10
trajin $SYSTEM/prod401-500ns.crd 1 last 10
trajin $SYSTEM/prod501-600ns.crd 1 last 10
trajin $SYSTEM/prod601-700ns.crd 1 last 10
trajin $SYSTEM/prod701-800ns.crd 1 last 10
trajin $SYSTEM/prod801-900ns.crd 1 last 10
trajin $SYSTEM/prod901-1000ns.crd 1 last 10

cluster c1 \ 
 kmeans clusters 10 randompoint maxit 500 \
 rms :1-585 \
 sieve 10 random \
 out $OUTPUT/kmeans_cnumvtime.dat \
 summary $OUTPUT/kmeans_summary.dat \
 info $OUTPUT/kmeans_info.dat \
 cpopvtime $OUTPUT/kmeans_cpopvtime.agr normframe \
 repout $OUTPUT/kmeans_rep repfmt pdb \
 singlerepout $OUTPUT/kmeans_singlerep.nc singlerepfmt netcdf \
 avgout $OUTPUT/kmeans_avg avgfmt pdb
run
EOF

module load amber
cpptraj -i cpptraj.in
wait
echo 'Done'
rm cpptraj.in
