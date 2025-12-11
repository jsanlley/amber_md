    #!/bin/bash
    module load amber

    pmemd.cuda -O -i min1.mdin -o _min1.mdout -p _solvated.prmtop -c _solvated.inpcrd -r _min1.rst -ref _solvated.inpcrd -inf _min1.info
    pmemd.cuda -O -i min2.mdin -o _min2.mdout -p _solvated.prmtop -c _min1.rst -r _min2.rst -ref _min1.rst -inf _min2.info 
    pmemd.cuda -O -i min3.mdin -o _min3.mdout -p _solvated.prmtop -c _min2.rst -r _min3.rst -ref _min2.rst -inf _min3.info
    pmemd.cuda -O -i min4.mdin -o _min4.mdout -p _solvated.prmtop -c _min3.rst -r _min4.rst -ref _min3.rst -inf _min4.info
    pmemd.cuda -O -i min5.mdin -o _min5.mdout -p _solvated.prmtop -c _min4.rst -r _min5.rst -ref _min4.rst -inf _min5.info
