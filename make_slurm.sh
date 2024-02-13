#job name syntax
# rep_ prod_ system_
#rep indicate replica number (for triplicates)
#prods broken down into 250ns intervals
#system defined as apo/ens (a, e (asymmetric) , ee (fully dimeric)) and monomeric(m)/dimeric)

#example: last production run for the third replica of the dimeric asymmetric ensitrelvir bound mpro
# $SBATCH --job-name= rep3_prod4_de

# $1 = system name (full)
# $2 = system name (abbreviated)
# $3 = replica number
# $4 = run number

#Make slurm script for running production runs
cat > run_prod.slurm << EOF
#!/bin/bash
#SBATCH --job-name=$2_r$3_p$4
#SBATCH --output=$1_%j.out
#SBATCH --partition=gpuA100x4
#SBATCH --mem=16g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --constraint="scratch"
#SBATCH --gpus-per-node=1
#SBATCH --gpu-bind=closest
#SBATCH --account=kif-delta-gpu
#SBATCH --no-requeue
#SBATCH -t 26:00:00

set -xv
source $HOME/.bashrc
conda activate amber

#pmemd.cuda -O -i prod.mdin -o $1_prod1.mdout -p $1_solvated.prmtop -c $1_equil.rst -r $1_prod1.rst -ref $1_equil.rst -inf $1_prod1.info -x $1_prod1.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod2.mdout -p $1_solvated.prmtop -c $1_prod1.rst -r $1_prod2.rst -ref $1_prod1.rst -inf $1_prod2.info -x $1_prod2.nc
pmemd.cuda -O -i prod.mdin -o $1_prod3.mdout -p $1_solvated.prmtop -c $1_prod2.rst -r $1_prod3.rst -ref $1_prod2.rst -inf $1_prod3.info -x $1_prod3.nc
#pmemd.cuda -O -i prod.mdin -o $1_prod4.mdout -p $1_solvated.prmtop -c $1_prod3.rst -r $1_prod4.rst -ref $1_prod3.rst -inf $1_prod4.info -x $1_prod4.nc
EOF

#Make slurm script to run all commands
cat > run_prep.slurm << EOF
#!/bin/bash
#SBATCH --job-name=prep_$2
#SBATCH --output=$1_prep_%j.out
#SBATCH --partition=gpuA100x4
#SBATCH --mem=16g
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --cpus-per-task=4
#SBATCH --constraint="scratch"
#SBATCH --gpus-per-node=1
#SBATCH --gpu-bind=closest
#SBATCH --account=kif-delta-gpu
#SBATCH --no-requeue
#SBATCH -t 2:00:00

set -xv
source $HOME/.bashrc
conda activate amber

pmemd.cuda -O -i rmin.mdin -o $1_rmin.mdout -p $1_solvated.prmtop -c $1_solvated.inpcrd -r $1_rmin.rst -ref $1_solvated.inpcrd -inf $1_rmin.info
pmemd.cuda -O -i umin.mdin -o $1_umin.mdout -p $1_solvated.prmtop -c $1_rmin.rst -r $1_umin.rst -ref $1_rmin.rst -inf $1_rmin.info
pmemd.cuda -O -i rheat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_umin.rst -r $1_rheat.rst -ref $1_umin.rst -inf $1_rheat.info -x $1_rheat.nc
pmemd.cuda -O -i heat.mdin -o $1_rheat.mdout -p $1_solvated.prmtop -c $1_rheat.rst -r $1_heat.rst -ref $1_rheat.rst -inf $1_heat.info -x $1_heat.nc
pmemd.cuda -O -i requil.mdin -o $1_requil.mdout -p $1_solvated.prmtop -c $1_heat.rst -r $1_requil.rst -ref $1_heat.rst -inf $1_requil.info -x $1_requil.nc
pmemd.cuda -O -i equil.mdin -o $1_equil.mdout -p $1_solvated.prmtop -c $1_requil.rst -r $1_equil.rst -ref $1_requil.rst -inf $1_equil.info -x $1_equil.nc
EOF

