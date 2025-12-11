#!/bin/bash
PWD=$(pwd)
name=$1 #mpro_apo_monomer
state=$2 # monomer/dimer/dimer_asym
traj_path="/net/gpfs-amarolab/jsanlleyhernandez/mpro-connecting-data/mpro_trajectories"
output=${traj_path}/mpro_nat_stripped/$name
module load amber

echo $output
mkdir -p "$output"

for rep in 1 2 3; do
	cd $traj_path/mpro_nat/$name
	
	if [[ "$state" == "monomer" ]]; then
		cat > remove_ligand.in << EOF
parm ${name}_dry_5k-at-500ps.prmtop
trajin ${name}_prod_aligned_dry_${rep}_5k-at-500ps.nc 1 last #dry trajectory for wisp analysis
strip :307-317,NME,ACE nobox parmout ${output}/${name}_stripped.prmtop # if state==monomer
trajout ${output}/${name}_stripped_${rep}.nc
trajout ${output}/${name}_stripped.pdb pdb onlyframes 1
EOF
cpptraj -i remove_ligand.in


	elif [[ "$state" == "dimer_asym" ]]; then
        	cat > remove_ligand.in << EOF
parm ${name}_dry_5k-at-500ps.prmtop
trajin ${name}_prod_aligned_dry_${rep}_5k-at-500ps.nc 1 last #dry trajectory for wisp analysis
strip :613-623,NME,ACE nobox parmout ${output}/${name}_stripped.prmtop # if state==monomer
trajout ${output}/${name}_stripped_${rep}.nc
trajout ${output}/${name}_stripped.pdb pdb onlyframes 1
EOF
cpptraj -i remove_ligand.in

	elif [[ "$state" == "dimer" ]]; then
        	cat > remove_ligand.in << EOF
parm ${name}_dry_5k-at-500ps.prmtop
trajin ${name}_prod_aligned_dry_${rep}_5k-at-500ps.nc 1 last #dry trajectory for wisp analysis
strip :613-633,NME,ACE nobox parmout ${output}/${name}_stripped.prmtop # if state==monomer
trajout ${output}/${name}_stripped_${rep}.nc
trajout ${output}/${name}_stripped.pdb pdb onlyframes 1

EOF
cpptraj -i remove_ligand.in

fi
cd $PWD
done

