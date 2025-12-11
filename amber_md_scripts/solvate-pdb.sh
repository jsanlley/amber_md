# missing logic for tleap volume script (simple)

#define pdb file name (or maybe just have a single pdb in the pdb directory)
pdb=$1

# SOLVATION (assuming pdb is "clean")
if [ -e ./pdb ] ; then
    echo 'file already exists...'
else
    mkdir pdb

    #Get volume from system (simple tleap script)
    cat > pdb/get_volume.in << EOF
    source leaprc.water.opc
    source leaprc.protein.ff19SB

    MPRO = loadpdb $pdb.pdb
    solvateoct MPRO OPCBOX 10 iso

    # extract volume from leap.log and calculate number of salts needed to match 0.150 and neutralize
    # use varibale for the next sctipt that returns ion # integer
EOF

    # solvate pdb with box volume
    cat > pdb/tleap-solvate.in << EOF
    source leaprc.gaff
    source leaprc.water.opc
    source leaprc.protein.ff19SB

    MPRO = loadpdb $2.pdb
    solvateoct MPRO OPCBOX 10 iso

    addionsrand MPRO Na+ 64 Cl- 64           #0.150M salt conc.
    addionsrand MPRO Na+ 6

    saveoff MPRO $1_solvated.lib                     #save off files
    saveamberparm MPRO $1_solvated.prmtop $1_solvated.inpcrd       #save parm
    savepdb MPRO $1_solvated.pdb                           #save pdb
    quit
EOF
fi