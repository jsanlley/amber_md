import sys
from schrodinger import structure 
from schrodinger.protein import seqres # seqres is a dictionary mapping chain names to residue names
from schrodinger.protein.buildpeptide import build_peptide
from schrodinger.structutils import build # mutate residues, create fragments at termini
from schrodinger.structutils.analyze import evaluate_asl, calculate_sasa

def describe_residue(st,chain,resnum):

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

def check_pdb(st):
    '''
    For each chain in the pdb file
    How many residues per chain (first and last)
    How many water molecules 
    Length of peptide per chain
    If enzyme, what is residue 145 (should be cysteine)
    How many solvent molecules (remove solvent)
    '''
    get_seqres = seqres.get_seqres(st) # not the actual number in sequence space (starts at 1)
    for chain in st.chain:
        residues = len(get_seqres)
        protein = evaluate_asl(st, f"chain {chain.name} and protein")
        waters = evaluate_asl(st, f"chain {chain.name} and water")
        solvent = evaluate_asl(st, f"chain {chain.name} and solvent and not water")
        missing = evaluate_asl(st,f"chain {chain.name} and not protein and not water and not solvent")
        total_residues = len(waters) + len(solvent) + len(get_seqres[chain.name])
        print(f"Chain object: {chain.name} ({residues} residues) ( {len(get_seqres[chain.name])} protein) ({len(waters)} waters) ({len(solvent)} solvent) {len(chain.residue)}")

def get_sequence(st): #done
    for chain in st.chain: # iterate over chains
        #print(f"Chain: {chain.name}")
        residues = chain.residue
        seq = []
        for res in residues:
            if res.getCode() == 'X':continue
            seq.append(res.getCode())
        print(f"Sequence: {''.join(seq) if len(seq) < 300 else ''} ({len(seq)} residues)")
        '''seq = []
        for res in chain.residue:
            if res.getCode() == 'X':continue
            seq.append(res.getCode())
        print(f"Sequence ({len(seq)} residues)")
        if len(seq) < 300:
            print("".join(seq))'''

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
                
                mutate_residues = build.mutate(
                    st, 
                    atom_in_res, 
                    target_resname)
                print(f"Mutating {resname} {res.chain} {res.resnum} -> {res.pdbres} {res.chain} {res.resnum}")

def extend_termini(st,resnum,fragname="GLN",termini='C'):
    '''
    Extend a given reisdue (terminal) by attaching fragment
    Attach fragment at N or C depending on the termini
    '''

    # Identify termini backbone atom
    for res in st.residue: # iterate over all residues
        if res.resnum == resnum: # find target residue
            fromatom = res.getBackboneNitrogen() if termini == "N" else res.getCarbonylCarbon()

    # Build fragment to attach
    fraggroup = build.get_frag_structure("peptide", fragname) # create fragment
    cap_residues = ['ACE','NMA']  # remove caps
    cap = []
    for a in fraggroup.atom: # iterate over atoms in fragment
        if a.pdbres.strip() in cap_residues: # select cap residues
            cap.append(a) # append to list
    fraggroup.deleteAtoms(cap) # delete framge nt atoms in list

    # obtain corresponding termini fragment atom
    if termini == 'C':
        toatom = next(a for a in fraggroup.atom if a.pdbname.strip() == "N")
        direction = 'backward' 
    else:
        toatom = next(a for a in fraggroup.atom if a.pdbname.strip() == "C")
        direction = 'forward'
    

    
    
    print(fromatom.index,toatom.index)
    build.connect(st,[str(fromatom.index)],[str(toatom.index)])
    

    


    



    direction = 'forward' if termini == 'N' else 'backward'
    print(direction)

    '''
    # Attach an amino-acid fragment (ALA) in the peptide library
    renum = build.attach_fragment(
        st,
        fromatom= # atom on which to make the attachment (if N-term on C elif C-term on N)
        toatom=, # atom to be replaced with the attachment (if N-term on N elif C-term on C)
        fraggroup="peptide",
        fragname=fragname, # if n term ser (S) if c term gln (Q)
        direction=direction,  # if n-term backwards else c term forwards              
        torsion_group="Secondary_Structure",
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
    
    check_pdb(st)
    extend_termini(st,305,fragname="GLN",termini='C')
    check_pdb(st)
    # describe pdb
    #check_pdb(st)

    # get sequence
    get_sequence(st)

    # remove solvent
    #remove_solvents(st)

    # extend peptide substrate
    #test_peptide = build_peptide("GACV")
    
    #get_sequence(st)
    #describe_residue(st,'A',145)
    

    
    # write modified structure to disk (as a mae file)
    modified_fname = f"{input_file[:-4]}-test"
    with structure.StructureWriter(f"{modified_fname}.pdb") as writer:
        writer.append(st)
    
if __name__ == "__main__":
    main()
