    #!/bin/bash
    module load amber

    echo 'Running rheat'
    pmemd.cuda -O -i rheat.mdin -o monomer_rheat.mdout -p monomer_solvated.prmtop -c monomer_min5.rst -r monomer_rheat.rst -ref monomer_min5.rst -inf monomer_rheat.info -x monomer_rheat.nc

    echo 'Running heat'
    pmemd.cuda -O -i heat.mdin -o monomer_heat.mdout -p monomer_solvated.prmtop -c monomer_rheat.rst -r monomer_heat.rst -ref monomer_rheat.rst -inf monomer_heat.info -x monomer_heat.nc
