#!/bin/bash

#start from a prepared protein (hydrogens added, loops modeled, protonation state estimated) (maestro)
#extract residue and ligand from pdb, make a copy with modified residue name and number (pdbtools?)
#cap custom amino acid residue with NME and ACE caps, create mc file (make_mc.py)
#change atom name for ligand from HETATM to ATOM, keep CONECT lines in pdb for converting to mol2 file using obabel
#have a copy of original pdb, pdb with modified aa, and pdbs of extracted residue,ligand,and modified reisdue (residue + ligand)

#run mainchain python script to generate .mc file

#make mol2 file from custom aa pdb (no hetatm, include conect records,same as residue in pdb)
obabel -i pdb nrm_145.pdb -o mol2 -O nrm_145.mol2

#create antechamber file to generate .ac file with amber atom types
antechamber -i nrm_145.mol2 -fi mol2 -o nrm_145.ac -fo ac -at amber -rn NRM -c bcc 

#run prepgen to generate prepin file
prepgen -i nrm_145.ac -o nrm_145.prepin -m nrm_a.mc -rn NRM

#run parmchk2 to generate frcmod files for tleap
parmchk2 -i nrm_145.prepin -f prepi -o nrm_145.frcmod -a Y -p $AMBERHOME/dat/leap/parm/parm19.dat

#if missing parameters for dihedrals, run following commands
`

#load custom aa parameter files to protein-ligand complex
cat < tleap_parm_test.in << EOF
source leaprc.protein.ff19SB
source leaprc.gaff
loadamberprep nirm_a_capped.prepin
loadamberparams nirm_a_capped.frcmod2
loadamberparams nirm_a_capped.frcmod1
x = loadpdb mpro_nirm_monomer.pdb
check x
EOF

tleap -f tleap_parm_test.in
