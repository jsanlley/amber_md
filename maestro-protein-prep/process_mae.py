from schrodinger import structure
from schrodinger.sructutils import build

# Goal: write protocol to process a set of pdb files containing peptide bound substrate using Maestro by:
# mutating C145A to wild type in both chains (A and B)
# remove solvent fragments
# add hydrogen/calculate titratable residues
# save pdb file in /maestro output

input_file = ".mae"
output_file = "./maestro"

# apply processing functions to structure object

# mutate C145A and C451A back to cysteines
def mutate_residues():
    st = structure.Structure.read(input_file)
    for res in st.residue:
        if res_chain == "A" and res_num == "145":
            target_res = res
            build.mutate_residue(target_res, "CYS")
    elif res_chain == "B" and res_num == "145":
            target_res = res
            build.mutate_residue(target_res, "CYS")

# run proteinprep protocol, remove solvent fragments, add hydrogens, calculate protonation states
def prepare_protein():
    pass

# placeholder: save prepared pdb file
def save_pdb():
    pass

try:
    with structure.StructureReader(input_file) as reader:
        with structure.StructureWriter(output_file) as writer:
            for st in reader:
                mutate_residues()
                prepare_protein()
                save_pdb
            # add processing logic
            pass



