    #!/bin/bash
    #SBATCH --job-name=_0_0
    #SBATCH --output=monomer_prod_rep_run_abv_%j.out
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
    #SBATCH -t 42:00:00

    set -xv
    source /Users/javingfun/.bashrc
    conda activate amber

    pmemd.cuda -O -i prod.mdin -o monomer_prod1.mdout -p monomer_solvated.prmtop -c monomer_equil.rst -r monomer_prod1.rst -ref monomer_equil.rst -inf monomer_prod1.info -x monomer_prod1.nc
    #pmemd.cuda -O -i prod.mdin -o monomer_prod2.mdout -p monomer_solvated.prmtop -c monomer_prod1.rst -r monomer_prod2.rst -ref monomer_prod1.rst -inf monomer_prod2.info -x monomer_prod2.nc
    #pmemd.cuda -O -i prod.mdin -o monomer_prod3.mdout -p monomer_solvated.prmtop -c monomer_prod2.rst -r monomer_prod3.rst -ref monomer_prod2.rst -inf monomer_prod3.info -x monomer_prod3.nc
    #pmemd.cuda -O -i prod.mdin -o monomer_prod4.mdout -p monomer_solvated.prmtop -c monomer_prod3.rst -r monomer_prod4.rst -ref monomer_prod3.rst -inf monomer_prod4.info -x monomer_prod4.nc
