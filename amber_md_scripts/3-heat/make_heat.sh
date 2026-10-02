#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 <monomer|dimer|dimer_asym> <system_name> [number_residues]" >&2
    exit 2
}

[[ $# -ge 2 && $# -le 3 ]] || usage

state=$1
system_name=$2

case "$state" in
    monomer)
        default_number_residues=306
        ligand_residue_count=1
        ;;
    dimer)
        default_number_residues=612
        ligand_residue_count=2
        ;;
    dimer_asym)
        default_number_residues=612
        ligand_residue_count=1
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
restraint_mask=":1-$((number_residues + ligand_residue_count))"
if [[ $state == monomer ]]; then
    restraint_mask=":1-$number_residues & :$((number_residues + 1))"
fi

cat > rheat.mdin << EOF
#Run 250ps of restrained heating (NVT)
 &cntrl
  imin=0,
  ntx=1,
  ntpr=2500,
  ntwr=2500,
  ntwx=2500,
  ntf=2,
  ntc=2,
  ntp=0,
  nscm=1000,
  ntb=1,
  nstlim=125000,
  dt=0.002,
  cut=10.0,
  iwrap=1,
  tempi=0,
  temp0=310.0,
  ntt=3,
  gamma_ln=5.0,
  ntr=1,
  restraint_wt=5.0,
  restraintmask='$restraint_mask',
/
EOF

cat > heat.mdin << EOF
#Run 250ps of unrestrained heating
 &cntrl
  imin=0,
  ntx=1,
  ntpr=2500,
  ntwr=2500,
  ntwx=2500,
  ntf=2,
  ntc=2,
  ntp=0,
  nscm=1000,
  ntb=1,
  nstlim=125000,
  dt=0.002,
  cut=10.0,
  iwrap=1,
  tempi=310.0,
  temp0=310.0,
  ntt=3,
  gamma_ln=5.0,
/
EOF

cat > run_heat.sh << EOF
#!/bin/bash

set -euo pipefail
module load amber

echo 'Running rheat'
pmemd.cuda -O -i rheat.mdin -o ${system_name}_rheat.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_min5.rst -r ${system_name}_rheat.rst -ref ${system_name}_min5.rst -inf ${system_name}_rheat.info -x ${system_name}_rheat.nc

echo 'Running heat'
pmemd.cuda -O -i heat.mdin -o ${system_name}_heat.mdout -p ${system_name}_solvated.prmtop -c ${system_name}_rheat.rst -r ${system_name}_heat.rst -ref ${system_name}_rheat.rst -inf ${system_name}_heat.info -x ${system_name}_heat.nc
EOF

chmod +x run_heat.sh
