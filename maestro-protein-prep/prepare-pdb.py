import sys
from schrodinger import structure 
from schrodinger.protein import seqres # seqres is a dictionary mapping chain names to residue names
from schrodinger.protein import buildpeptide, pdbname
from schrodinger.structutils import build # mutate residues, create fragments at termini
from schrodinger.structutils import analyze

def check_pdb(st): # done (as much as it can)
    '''
    For each chain in the pdb file
    How many residues per chain (first and last)
    How many water molecules 
    Length of peptide per chain
    If enzyme, what is residue 145 (should be cysteine)
    How many solvent molecules (remove solvent)
    '''
    for chain in st.chain:
        seq = []
        waters = analyze.evaluate_asl(st, f'(chain.name "{chain.name}" AND water)')
        solvent = 0
        for res in chain.residue:
            if (res.getCode() == 'X'):
                 if (res.pdbres.strip() != 'HOH'): # including solvent and water
                    solvent += 1
            else:
                seq.append(res.getCode())

        seq_str = ''.join(seq)
        if len(seq_str) > 12 and len(seq_str) != 306:
            if seq_str[0:5] != 'SGFRK':
                pass
            elif seq_str[-5:] != 'GVTFQ':
                pass
        print(f"Chain {chain.name}: Sequence: {seq_str if len(seq) < 300 else ''} ({len(seq)} residues)) ({len(waters)} waters) ({solvent} solvent)")

def remove_solvents(st): # done 
    solvents = ["DMS","GOL"]
    solvent_atoms = [] 
    print(f"Removing solvents ({' '.join(solvents)})...") # this works
    for res in st.residue:
        if res.pdbres.strip() in solvents:
            solvent_atoms.extend(st.atom[i] for i in res.getAtomIndices()) # append selection to empty list
    st.deleteAtoms(solvent_atoms) # check to see if atoms have been deleted

def make_mutations(st): # done
    mutations = [(145, "CYS")]
    print(f"Mutating catalytic residues ({':'.join([str(x) for x in mutations[0]])})...")
    for res in st.residue: # iterate over all residues
        for target_resnum, target_resname in mutations:
            if res.resnum == target_resnum:  # find C145A in chain A and B
                resname = res.pdbres.strip()
                atom_in_res = res.getAtomIndices()[0] # get first index of atom
                mutate_residues = build.mutate(st, atom_in_res, target_resname) # mutate residues

def extend_termini(st,resnum=305,termini='C',fragment="Q",chainid='A'): #missing: fragment can be attached but cannot resolve fragment numbering
    '''
    fragment: create a fragment without caps (done)
    append fragment to termini (N or C) at a given resnum
    define residue number to attach fragment
    '''

    # create peptide fragment
    frag_st = buildpeptide.build_peptide(
        fragment,
        secondary_structure=buildpeptide.SECONDARY_STRUCTURE(1),
        cap=False) # creates a structure module)

    # this solves the connectivity problem but its not integrated
    pdbname.assign_pdb_names(
        frag_st,
        rename_residues=True,
        rename_atoms=True,
        backbone_detection_size=1
    )
    
    # renumber fragment residues at the atom level
    for res in frag_st.residue:
        for a in res.atom:
            a.chain = chainid
            a.resnum = resnum+1 if termini=='C' else res[1].resnum-1
            a.inscode = " "   # critical: avoid collisions like 305A

    def get_fragment_residue_atom_indices(frag_st):
        # renumber fragment residues
        '''pdbname.renumber_residues(
            frag_st,
            chains=chainid,
            start_resnum=resnum+1 if termini == "C" else 1
        )'''
        if termini == 'C': # attach N termini atoms to C termini of peptide
            for atom in frag_st.atom: # for all atoms in the residue
                if atom.pdbname.strip() == 'H1': # atom in fragment to replace 
                    frag_atom_to = atom.index
                if atom.pdbname.strip() == 'N': # atom in fragment to attach
                    frag_atom_from = atom.index 
        else: # define c termini of fragment (not explicit for some reason...)
            extra = []
            for atom in frag_st.atom:
                if atom.pdbname.strip() == 'C':
                    frag_atom_from = atom.index # c termini backbone atom to attach
                if atom.pdbname.strip() == 'OXT':
                    frag_atom_to = atom.index
                if atom.pdbname == 'H1':
                    extra.append(atom)
            frag_st.deleteAtoms(extra)
        return frag_atom_to,frag_atom_from
    
    def get_termini_residue_atom_indices(st):
        '''
        Get terminal atom indices for a given chain, residue and terminal site (N or C)
        '''
        for chain in st.chain: # iterate over chain
            if chainid != chain.name: continue
            for res in chain.residue: # for all residues in the structure
                if res.resnum != resnum: continue # find the residue you are looking for
                print(f"Extending on {res.chain.strip()} {res.pdbres.strip()} {res.resnum} ({termini} termini)")
                if termini == 'C': # define c termini atoms
                    for atom in res.atom: # for all atoms in the residue
                        if atom.pdbname.strip() == 'HXT': 
                            st_atom_to = atom.index
                        if atom.pdbname.strip() == 'C':
                            st_atom_from = atom.index 
                else: # define n termini atoms
                    for atom in res.atom: # for all atoms in the residue
                        if atom.pdbname.strip() == 'H1': # peptide n termini atom to replace
                            st_atom_to = atom.index
                        if atom.pdbname.strip() == 'N': # peptide n termini atom to attach
                            st_atom_from = atom.index
            return st_atom_to,st_atom_from

    def debug_fragment_ids(frag_st):
        for res in frag_st.residue:
            # show the first atom’s identity as representative
            a0 = res.atom[1]
            print("RES:", res.pdbres, "resobj_resnum:", getattr(res, "resnum", None),
                "atom_resnum:", a0.resnum, "chain:", a0.chain, "inscode:", repr(a0.inscode))

    st_atom_to,st_atom_from = get_termini_residue_atom_indices(st)
    frag_atom_to,frag_atom_from = get_fragment_residue_atom_indices(frag_st)
    debug_fragment_ids(frag_st)

    renumber_map = build.attach_structure(
        st, #done
        st_atom_from, # atom to connect the fragment to 
        st_atom_to, # atom to replace with fragment
        frag_st, #done
        frag_atom_from, # fragment atom to connect with structure
        frag_atom_to) # fragment atom to replace

def example(st,chain,resnum):
    catalytic = st.findResidue(f'{chain}:{resnum}') # get residue name (structure object)
    # iterate over chain
    # class schrodinger.structure._Chain(st, chain, atoms)
    for chain in st.chain: # iterate over chains
        if chain.name != 'A': continue # filter by chain
        residues = chain.residue # proprty that returns a residue iterator

        # class schrodinger.structure.Residue(st, resnum, inscode, chain, atoms=[])    
        for res in residues: # iterate over residues
            seq = []
            if res.getCode() == 'X':continue
            seq.append(res.getCode())
            print(f"Sequence: {''.join(seq) if len(seq) < 300 else ''} ({len(seq)} residues)")
            if res.resnum != resnum: continue # filter by residue
            
            # get residue info
            resname = res.pdbres # residue name
            reschain = res.chain # residue chain
            rescode = res.getCode() # one letter pdb code
            atom_indices = res.getAtomIndices() # obtain atom indices
            new_st = res.extractStructure() # create a new structure from selection

            # get backbone atoms
            bbn = res.getBackboneNitrogen() 
            bbc = res.getCarbonylCarbon()
            bbo = res.getBackboneOxygen()
            asl = res.getAsl()

            print(f"{resname} {reschain} {resnum}") # resname, chain, resnum
            print(f"PDB one-letter code: {rescode}") # one letter code
            print(f"indices: ({atom_indices})") #
            
            #class schrodinger.structure.StructureAtom(ct, cpp_atom)
            for atom in res.atom: # filter by atom
                pdbname = atom.pdbname
                pdbcode = atom.pdbcode
                print(atom.getResidue(), atom.pdbname, atom.resnum)
        

    for res in st.residue: # iterate over all residues
        if res.resnum == resnum: # find target residue
            fromatom = res.getBackboneNitrogen() if termini == "N" else res.getCarbonylCarbon()

def create_and_renumber_fragment(
        chainid="A",
        fragment='Q',
        resnum=305,
        termini='C',
        assign_pdb_names=True,
        renumber=True):
        
        # create peptide fragment
        frag_st = buildpeptide.build_peptide(
            fragment,
            secondary_structure=buildpeptide.SECONDARY_STRUCTURE(1)) # creates a structure module)
        
        if assign_pdb_names:
            print('assigning pdb_names')
            pdbname.assign_pdb_names(
            frag_st,
            rename_residues=True,
            rename_atoms=True,
            backbone_detection_size=1
            )
            for res in frag_st.residue:
                for a in res.atom:
                    print(a.resnum,a.pdbname)

        if renumber:
            print('renumbering residues')
            # renumber fragment residues at the atom level
            for res in frag_st.residue:
                for a in res.atom:
                    print(a.resnum,a.pdbname)
                    a.chain = chainid
                    a.resnum = resnum+1 if termini=='C' else res[1].resnum-1
                    a.inscode = " "   # critical: avoid collisions like 305A
            
        return frag_st    
        
def main():
    '''
    Remove solvent fragments (anything not water or protein)
    Add hydrogens
    Mutate catalytic residue

    Extend c termini of peptide substrate
    Extend n termini of peptide substrate
    Extend c termini of enzyme
    Extend n termini of enzyme
    '''



    if len(sys.argv) < 1: # print out logic for command usage
        print("Usage: python prepare_pdb.py input.pdb")
        sys.exit()
    
    input_file = sys.argv[1]
    print(f"Loading {input_file} ...")
    
    st = structure.StructureReader.read(input_file) # read in pdb file as structure
    remove_solvents(st)
    print("Adding hydrogens...")
    build.add_hydrogens(st)
    make_mutations(st)

    '''extend_termini(
        st,
        resnum=305,
        termini='C',
        fragment="Q",
        chainid='A'
        )'''

    frag_st = create_and_renumber_fragment(
        chainid="A",
        fragment='Q',
        resnum=305,
        termini='C',
        assign_pdb_names=True,
        renumber=True
    )

    # write modified structure to disk (as a mae file)
    modified_fname = f"{input_file[:-4]}-frag"
    with structure.StructureWriter(f"{modified_fname}.pdb") as writer:
        writer.append(frag_st)
    
if __name__ == "__main__":
    main()