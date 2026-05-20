#Written by A.Ojha

def rename_chlorine_in_pdb_file(pdb_file):
    # Read the content of the PDB file
    with open(pdb_file, 'r') as file:
        content = file.read()
    # Replace 'CL' with 'Cl'
    updated_content = content.replace('CL', 'Cl')
    # Overwrite the file with the updated content
    with open(pdb_file, 'w') as file:
        file.write(updated_content)

def restructure_pdb(pdb_file):
    # Generate the temporary output file name
    temp_output_file = 'temp.pdb'
    # Build the antechamber command
    command = f'pdb4amber -i {pdb_file} -o {temp_output_file} --noter --no-conect'
    print(command)
    # Run the antechamber command
    os.system(command)
    # Rename the temporary output file to the original file name
    os.rename(temp_output_file, pdb_file)
    command = "rm -rf *temp*"
    os.system(command)

def run_antechamber_commands(ligand):
    subprocess.run(["obabel", f"{ligand}.pdb", "-O", f"{ligand}.mol2"])
    subprocess.run(["antechamber", "-i", f"{ligand}.mol2", "-fi", "mol2", "-o", f"{ligand}.prepin", "-fo", "prepi", "-c", "bcc", "-s", "2", "-pf", "y"])
    subprocess.run(["parmchk2", "-i", f"{ligand}.prepin", "-f", "prepi", "-o", f"{ligand}.frcmod"])
    subprocess.run(["mv", "sqm.in", f"{ligand}_sqm.in"])
    subprocess.run(["mv", "sqm.pdb", f"{ligand}_sqm.pdb"])
    subprocess.run(["mv", "sqm.out", f"{ligand}_sqm.out"])
