"""
Copy PDB file into the build/pdb file and run the following commands (from the maestro bash scripts)
"""

import os
import shutil
import glob
import subprocess

def copy_file(src, dest, pattern):
    """
    Copies a file based on pattern (*pdb)

    Args:
        src (str): Source directory file files
        dest (str): Destination directory file files
        pattern (str): Pattern to match (e.g. '*pdb')
    """

    #Create list of matches
    matched_files = glob.glob(os.path.join(src,pattern))

    if not matched_files:
        print("File not found")
        return

    # Iterate over match list and copy to pdb file
    for match_path in matched_files:
        try:
            name = os.path.basename(match_path)
            print(name)

            dest_path = os.path.join(dest, name)

            shutil.copy2(match_path, dest_path)
            print(f"Copied file from {src} to {dest}")
        except FileNotFoundError:
            print(f"Source file not found: {src}")
        except Exception as e:
            print(f"Error copying file: {e}")

def run_maestro_command(*args):
    """
    Create a maestro .mae file from the .pdb file in the directory
    """
    script_path = "/maestro_proteinprep.sh"
    command = ["bash",script_path]+ list(args)
    command_test = ['. ~/scripts/maestro_proteinprep.sh', '8dz0']

    result = subprocess.run(command_test, shell=True, capture_output=True)
    print(result)
    return result


if __name__ == "__main__":

    #define working and output directories
    system_dir = os.path.abspath('mpro_tools/tests')
    output_dir = os.path.join(system_dir,'system/build/pdb')
    print(system_dir)
    print(output_dir)



