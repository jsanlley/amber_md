    #!/bin/bash
    module load amber

    echo 'Running requil'
    pmemd.cuda -O -i requil.mdin -o monomer_requil.mdout -p monomer_solvated.prmtop -c monomer_heat.rst -r monomer_requil.rst -ref monomer_heat.rst -inf monomer_requil.info -x monomer_requil.nc

    echo 'Running equil'
    pmemd.cuda -O -i equil.mdin -o monomer_equil.mdout -p monomer_solvated.prmtop -c monomer_requil.rst -r monomer_equil.rst -ref monomer_requil.rst -inf monomer_equil.info -x monomer_equil.nc
