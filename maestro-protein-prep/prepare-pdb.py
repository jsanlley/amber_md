import sys
from schrodinger import structure 
from schrodinger.protein import seqres # seqres is a dictionary mapping chain names to residue names
from schrodinger.structutils import build
from schrodinger.structutils import analyze

def check_pdb(st):
    get_seqres = seqres.get_seqres(st) # not the actual number in sequence space (starts at 1)
    print('iterating over chains')
    for chain in st.chain:
        print(f"Chain object: {chain.name} \nchain.residue {chain.residue}")
        print(chain.getAtomIndices())
        for res in chain.residue: 
            print(f"residue {res}")
        #print(f"Chain: {st.chain} ({len(res)} residues)")

def get_sequence(st):
    for chain in st.chain: # iterate over chains
        print(f"Chain: {chain.name}")
        seq = []
        for res in chain.residue:
            if res.getCode() == 'X':continue
            seq.append(res.getCode())
        print(f"Sequence ({len(seq)} residues)")
        print("".join(seq))

def remove_solvents(st):
    solvents = ["DMS","GOL"]
    solvent_atoms = [] 
    print(f"Removing solvents ({' '.join(solvents)})...") # this works
    for res in st.residue:
        if res.pdbres.strip() in solvents:
            solvent_atoms.extend(st.atom[i] for i in res.getAtomIndices())
    st.deleteAtoms(solvent_atoms) # check to see if atoms have been deleted

def make_mutations(st):
    mutations = [(145, "CYS")]
    print(f"Mutating catalytic residues ({':'.join([str(x) for x in mutations[0]])})...")
    for res in st.residue: # iterate over all residues
        for target_resnum, target_resname in mutations:
            if res.resnum == target_resnum:  # find C145A in chain A and B
                resname = res.pdbres.strip()
                atom_in_res = res.getAtomIndices()[0]
                
                mutate_residues = build.mutate(
                    st, 
                    atom_in_res, 
                    target_resname)
                print(f"Mutating {resname} {res.chain} {res.resnum} -> {res.pdbres} {res.chain} {res.resnum}")

def extend_termini(st,residue,fragname="GLN",termini='C'):
    # build fragments (remove default caps)
    fraggroup = build.get_frag_structure("peptide", fragname)
    cap_residues = ['ACE','NMA']
    cap = []
    for a in fraggroup.atom:
        if a.pdbres.strip() in cap_residues:
            cap.append(a)
    fraggroup.deleteAtoms(cap)

    fromatom = next(a for a in fraggroup.atom if a.pdbname.strip() == "N")
    print(fromatom, type(fromatom))

    for res in st.residue: # iterate over all residues
        if res.resnum == residue: # find target residue
            terminal = res.resnum
            resname = res.pdbres.strip()
            print(terminal, resname)


    direction = 'forward' if termini == 'N' else 'backward'
    print(direction)

    '''
    # Attach an amino-acid fragment (ALA) in the peptide library
    renum = build.attach_fragment(
        st,
        fromatom= # atom on which to make the attachment (if N-term on C elif C-term on N)
        toatom=, # atom to be replaced with the attachment (if N-term on N elif C-term on C)
        fraggroup= ""peptide",
        fragname="", # if n term ser (S) if c term gln (Q)
        direction="forward(N-to-C)",  # if n-term backwards else c term forwards              
        torsion_group="Secondary_Structure:",
        conformation="extended"
    )'''
    #print(f"chain {chain.name}: {residues}")
    # number of waters
    # number of solvent atoms
    # number of residues in protein
    # first and last residue
    

def main():

    if len(sys.argv) < 1: # print out logic for command usage
        print("Usage: python prepare_pdb.py input.pdb")
        sys.exit()
    
    input_file = sys.argv[1]
    print(f"Loading {input_file} ...")
    st = structure.StructureReader.read(input_file) # read in pdb file as structure

    print("Checking pdb...")
    #get_sequence(st)
    check_pdb(st)
    #remove_solvents(st)
    #make_mutations(st)
    #extend_termini(st,305)
    

    
    # write modified structure to disk (as a mae file)
    modified_fname = f"{input_file[:-4]}-test"
    with structure.StructureWriter(f"{modified_fname}.pdb") as writer:
        writer.append(st)
    
if __name__ == "__main__":
    main()
