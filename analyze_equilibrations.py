import argparse
import mdtraj as md
import pandas as pd
import matplotlib.pyplot as plt

def create_ag_parser():
    parser = argparse.ArgumentParser(description="Program to create plots to check for equilibration results")
    parser.add_argument("-t", "--trajectory", type=str, help="The path of the trajectory to analyze")
    parser.add_argument("-to", "--topology", type=str, help="The path of the topology to analyze")
    parser.add_argument("-c", "--csv_file", type=str, help="The path of the csv file from the simulation")
    parser.add_argument("-o", "--output", type=str, default="equilibration_analysis.svg", help="The name of outputs with extension")
    return parser

def main(trajectory, topology, csv_file, output):
    print("Loading Trajectory")
    traj = md.load(trajectory, top=topology)

    print("Selecting backbone atoms")
    backbone_indices = traj.topology.select('protein and backbone')

    print("Aligning trajectory to first frame")
    traj.image_molecules(inplace=True)
    traj.superpose(traj[0], atom_indices=backbone_indices)

    print("Calculating RMSD")
    rmsd = md.rmsd(traj, traj, frame=0, atom_indices=backbone_indices)
    time = traj.time

    print("Reading the log file")
    df = pd.read_csv(csv_file)
    print(df.columns)

    print("Making figure with properties")
    fig, axs = plt.subplots(2, 2, figsize=(14, 10))

    axs[0, 0].plot(df['Step'], df['Temperature (K)'], color='tab:red')
    axs[0, 0].set_xlabel("Step")
    axs[0, 0].set_title('Temperature (K)')

    axs[0, 1].plot(df['Step'], df['Potential Energy (kJ/mole)'], color='tab:blue')
    axs[0, 1].set_xlabel("Step")
    axs[0, 1].set_title('Potential Energy (kJ/mol)')

    axs[1, 0].plot(time, rmsd, color='tab:green')
    axs[1, 0].set_xlabel("Frame")
    axs[1, 0].set_title('RMSD (nm)')

    axs[1, 1].plot(df['Step'], df['Box Volume (nm^3)'], color='tab:orange')
    axs[1, 1].set_xlabel("Step")
    axs[1, 1].set_title('Box Volume (nm^3)')

    for ax in axs.flat:
        ax.grid(True)

    plt.tight_layout()
    plt.savefig(output, dpi=300, bbox_inches='tight')
    print(f"Plot saved as {output}")

if __name__ == "__main__":
    parser = create_ag_parser()
    args = parser.parse_args()
    main(args.trajectory, args.topology, args.csv_file, args.output)
