    #!/bin/bash
    module load amber

    pmemd.cuda -O -i min1.mdin -o monomer_min1.mdout -p monomer_solvated.prmtop -c monomer_solvated.inpcrd -r monomer_min1.rst -ref monomer_solvated.inpcrd -inf monomer_min1.info
    pmemd.cuda -O -i min2.mdin -o monomer_min2.mdout -p monomer_solvated.prmtop -c monomer_min1.rst -r monomer_min2.rst -ref monomer_min1.rst -inf monomer_min2.info 
    pmemd.cuda -O -i min3.mdin -o monomer_min3.mdout -p monomer_solvated.prmtop -c monomer_min2.rst -r monomer_min3.rst -ref monomer_min2.rst -inf monomer_min3.info
    pmemd.cuda -O -i min4.mdin -o monomer_min4.mdout -p monomer_solvated.prmtop -c monomer_min3.rst -r monomer_min4.rst -ref monomer_min3.rst -inf monomer_min4.info
    pmemd.cuda -O -i min5.mdin -o monomer_min5.mdout -p monomer_solvated.prmtop -c monomer_min4.rst -r monomer_min5.rst -ref monomer_min4.rst -inf monomer_min5.info
