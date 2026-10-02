#!/bin/bash

set -euo pipefail

usage() {
  echo "Usage: $0 <monomer|dimer|dimer_asym|apo_monomer|apo_dimer> <system_name> [number_residues]" >&2
    exit 2
}

[[ $# -ge 2 && $# -le 3 ]] || usage

state=$1
system_name=$2

case "$state" in
    monomer)
      default_number_residues=306
      ligand_residue_count=1
        include_ligand_stage=1
        ;;
    dimer)
      default_number_residues=612
      ligand_residue_count=2
        include_ligand_stage=1
        ;;
    dimer_asym)
      default_number_residues=612
      ligand_residue_count=1
        include_ligand_stage=1
        ;;
    apo_monomer)
      default_number_residues=306
      ligand_residue_count=0
        include_ligand_stage=0
        ;;
    apo_dimer)
      default_number_residues=612
      ligand_residue_count=0
        include_ligand_stage=0
        ;;
    *)
        echo "Unknown state: $state" >&2
        usage
        ;;
esac

number_residues=${3:-$default_number_residues}
[[ $number_residues =~ ^[0-9]+$ ]] || {
  echo "number_residues must be an integer: $number_residues" >&2
  exit 2
}
protein_mask=":1-$number_residues"
if [[ $include_ligand_stage -eq 1 ]]; then
  ligand_start=$((number_residues + 1))
  ligand_end=$((number_residues + ligand_residue_count))
  ligand_mask=":$ligand_start"
  [[ $ligand_residue_count -gt 1 ]] && ligand_mask=":$ligand_start-$ligand_end"
fi

cat > min1.mdin << EOF
# Strong minimization with restraints on non-hydrogen atoms
&cntrl
  imin=1,
  ntx=1,
  irest=0,
  ntpr=50,
  ntr=1,
  restraint_wt=100.0,
  restraintmask='!@H=',
  maxcyc=500,
  ntmin=1,
  ncyc=500,
/
EOF

cat > min2.mdin << EOF
# Moderate minimization with restraints on protein heavy atoms
&cntrl
  imin=1,
  ntx=1,
  irest=0,
  ntpr=50,
  ntr=1,
  restraint_wt=50.0,
  restraintmask='$protein_mask & !@H=',
  maxcyc=500,
  ntmin=1,
  ncyc=500,
/
EOF

cat > min3.mdin << EOF
# Soft minimization with restraints on protein backbone atoms
&cntrl
  imin=1,
  ntx=1,
  irest=0,
  ntpr=50,
  ntr=1,
  restraint_wt=10.0,
  restraintmask='$protein_mask@CA,N,C,O',
  maxcyc=500,
  ntmin=1,
  ncyc=500,
/
EOF

if [[ $include_ligand_stage -eq 1 ]]; then
    cat > min4.mdin << EOF
# Soft minimization with restraints on ligand heavy atoms
&cntrl
  imin=1,
  ntx=1,
  irest=0,
  ntpr=50,
  ntr=1,
  restraint_wt=10.0,
  restraintmask='$ligand_mask & !@H=',
  maxcyc=500,
  ntmin=1,
  ncyc=500,
/
EOF
fi

cat > min5.mdin << EOF
# Unrestrained minimization
&cntrl
  imin=1,
  ntx=1,
  irest=0,
  ntpr=50,
  maxcyc=40000,
  ntmin=1,
/
EOF

cat > run_min.sh << EOF
#!/bin/bash

set -euo pipefail
module load amber

pmemd.cuda -O -i min1.mdin -o ${system_name}_min1.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_solvated.inpcrd -r ${system_name}_min1.rst -ref ${system_name}_solvated.inpcrd -inf ${system_name}_min1.info
pmemd.cuda -O -i min2.mdin -o ${system_name}_min2.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_min1.rst -r ${system_name}_min2.rst -ref ${system_name}_min1.rst -inf ${system_name}_min2.info
pmemd.cuda -O -i min3.mdin -o ${system_name}_min3.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_min2.rst -r ${system_name}_min3.rst -ref ${system_name}_min2.rst -inf ${system_name}_min3.info
EOF

if [[ $include_ligand_stage -eq 1 ]]; then
    cat >> run_min.sh << EOF
pmemd.cuda -O -i min4.mdin -o ${system_name}_min4.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_min3.rst -r ${system_name}_min4.rst -ref ${system_name}_min3.rst -inf ${system_name}_min4.info
pmemd.cuda -O -i min5.mdin -o ${system_name}_min5.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_min4.rst -r ${system_name}_min5.rst -ref ${system_name}_min4.rst -inf ${system_name}_min5.info
EOF
else
    cat >> run_min.sh << EOF
pmemd.cuda -O -i min5.mdin -o ${system_name}_min5.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_min3.rst -r ${system_name}_min5.rst -ref ${system_name}_min3.rst -inf ${system_name}_min5.info
EOF
fi

chmod +x run_min.sh
