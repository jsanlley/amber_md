#!/bin/bash
path='/net/gpfs-amarolab/jsanlleyhernandez/mpro_trajectories_sztain'
ls $path
systems=('6LU7_dimer_2N3'
	'6LU7_dimer_2N3_covalent'
	'6LU7_dimer_apo'
	'6LU7_dimer_N3'
	'6LU7_monomer_apo'
	'6LU7_monomer_N3')

#loop over every system
#copy cluster summaries and frames to cluster_output_directory

for system in ${systems[@]}; do
	echo $system
	input=$path/'TRAJECTORIES_main_protease_6LU7_amarolab'/$system
	output=$path/clustering_output/$system

	mkdir $output
	cp $input/*prmtop $output
	cp $input/clustering_output/* $output
done

