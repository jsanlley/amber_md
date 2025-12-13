import sys
from schrodinger import structure
from schrodinger.protein import seqres # seqres is a dictionary mapping chain names to residue names
from schrodinger.structutils import build

def main():

    if len(sys.argv) < 1:
        print("Usage: python prepare_pdb.py input.pdb")
        sys.exit(1)

    input_file = sys.argv[1]

    # read in pdb file
    st = structure.StructureReader.read(input_file)
    print("structure")
    print(st)

    print("sequence")
    print(seqres.get_seqres(st))

    # delete solvent fragments
    solvents = ["DMS","GOL"]



    # reverse mutation in C145A to alanine
    res, *_ = st.residue
    print(res,*_)
    print(res.getAtomIndices())

    # delete solvent fragments (non canonical)

    # write modified structure to disk (as a mae file)
    modified_fname = f"{input_file[:-4]}.mae"
    with structure.StructureWriter(f"maestro/{modified_fname}") as writer:
        writer.append(st)

if __name__ == "__main__":
    main()