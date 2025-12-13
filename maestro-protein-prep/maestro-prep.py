import os
import sys
import subprocess

# Path to your Schrödinger installation
SCHRO = "/software/repo/moleculardynamics/schrodinger/2025u2"
STRUCTCONVERT = os.path.join(SCHRO, "utilities", "structconvert")

def main():
    
    if len(sys.argv) < 3:
        print("Usage: python convert_pdb_to_mae.py input.pdb output.mae")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    # Build the command
    cmd = [STRUCTCONVERT, input_file, f'maestro/{output_file}']
    print("Running:", " ".join(cmd))
    
    # Execute the Schrödinger structconvert tool
    subprocess.run(cmd, check=True)

    print(f"Conversion complete: {input_file} → {output_file}")

if __name__ == "__main__":
    main()
