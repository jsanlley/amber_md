"""
This script uses metadynamics to pull the ligand out of the pocket.
"""

import sys
import time
from sys import stdout
from simtk import unit
from simtk import openmm
from simtk.openmm import app
import matplotlib.pyplot as plt
import numpy as np
import parmed

kcal_per_mole = unit.kilocalories / unit.mole
kJ_per_mol = unit.kilojoules / unit.mole

iso_indices1 = [4786]
iso_indices2 = [4825]

com_indices1 = [479, 498, 594, 843, 1306, 1568, 1583, 1603, 1630, 
                1636, 1654, 1665, 2422, 2436, 2471]
com_indices2 = [4781, 4785, 4786, 4787, 4789, 4791, 4793, 4794, 
                4795, 4796, 4798, 4799, 4800, 4801, 4802, 4805, 
                4806, 4808, 4810, 4811, 4812, 4813, 4816, 4817, 
                4819, 4822, 4825, 4828, 4831]

#prmtop_filename = "/home/lvotapka/jak/II_system_preparation/jak_1_1fvaq_5/system_TP4EW_I.parm7"
prmtop_filename = "system_TP4EW_I.parm7"
#pdb_filename = "/home/lvotapka/jak/II_system_preparation/jak_1_1fvaq_5/system_nvt_output_last_frame.pdb"
pdb_filename = "system_nvt_output_last_frame.pdb"

box_vectors = parmed.load_file(pdb_filename).box_vectors
box_vectors_nm = box_vectors.value_in_unit(parmed.unit.nanometers)

temperature = 298.15*unit.kelvin

cuda_device_index = "0"
nonbonded_cutoff = 0.9*unit.nanometer

# time step of simulation 
time_step = 0.002 * unit.picoseconds

#optionally print a trajectory
trajectory_filename = "metadyn_1fvaq_trajectory.pdb"
trajectory_interval = 50000

# total number of timesteps to take in the metadynamics simulation
num_steps = 20000000 # 40 ns

npoints = 181
sigma = 0.05 * unit.nanometers
nsteps = 250
height = 2.0 * kJ_per_mol
biasFactor = 10.0

prmtop = app.AmberPrmtopFile(prmtop_filename)
#inpcrd = app.AmberInpcrdFile(inpcrd_filename)
mypdb = app.PDBFile(pdb_filename)

system = prmtop.createSystem(
    nonbondedMethod=app.PME, nonbondedCutoff=nonbonded_cutoff, 
    constraints=app.HBonds)


# Keep the system from escaping out too far
barrier_distance = 1.75 * unit.nanometer
barrier_spring_constant = 9000.0 * unit.kilojoules_per_mole * unit.nanometers**2
barrier_force = openmm.CustomCentroidBondForce(
    2, "0.5*k*step(distance(g1, g2) - radius)*(distance(g1, g2) - radius)^2")
barrier_group1a = barrier_force.addGroup(com_indices1)
barrier_group2a = barrier_force.addGroup(com_indices2)
barrier_force.setForceGroup(1)
barrier_force.addPerBondParameter("k")
barrier_force.addPerBondParameter("radius")
barrier_force.addBond([barrier_group1a, barrier_group2a], [barrier_spring_constant, barrier_distance])
barrier_forcenum = system.addForce(barrier_force)


myforce1 = openmm.CustomCentroidBondForce(
    2, "distance(g1, g2)")
mygroup1a = myforce1.addGroup(com_indices1)
mygroup1b = myforce1.addGroup(com_indices2)
myforce1.addBond([mygroup1a, mygroup1b], [])

myforce1_bias = app.BiasVariable(
    myforce1, minValue=0.0*unit.nanometers, maxValue=2.0*unit.nanometers,
    biasWidth=sigma, periodic=False, gridWidth=npoints)
    
myforce2 = openmm.CustomCentroidBondForce(
    2, "distance(g1, g2)")
mygroup2a = myforce2.addGroup(iso_indices1)
mygroup2b = myforce2.addGroup(iso_indices2)
myforce2.addBond([mygroup2a, mygroup2b], [])

myforce2_bias = app.BiasVariable(
    myforce2, minValue=0.0*unit.nanometers, maxValue=2.0*unit.nanometers,
    biasWidth=sigma, periodic=False, gridWidth=npoints)
    
meta = app.Metadynamics(
    system, variables=[myforce1_bias, myforce2_bias], temperature=temperature,
    biasFactor=biasFactor, height=height, frequency=nsteps)

integrator = openmm.LangevinIntegrator(temperature, 1/unit.picosecond, 
    time_step)
platform = openmm.Platform.getPlatformByName("CUDA")
properties = {"CudaDeviceIndex": cuda_device_index, "CudaPrecision": "mixed"}
simulation = app.Simulation(prmtop.topology, system, integrator, platform, 
                        properties)

#if inpcrd.boxVectors is not None:
#    simulation.context.setPeriodicBoxVectors(*inpcrd.boxVectors)

simulation.context.setPeriodicBoxVectors(*box_vectors_nm)

simulation.context.setPositions(mypdb.positions)
simulation.context.setVelocitiesToTemperature(temperature)
simulation.minimizeEnergy()

simulation.reporters.append(app.StateDataReporter(
    stdout, 100, step=True, potentialEnergy=True, temperature=True,
))
if trajectory_filename and trajectory_interval:
    pdb_reporter = app.PDBReporter(trajectory_filename, trajectory_interval)
    simulation.reporters.append(pdb_reporter)

start_time = time.time()
meta.step(simulation, num_steps)
total_time = time.time() - start_time
simulation_in_ns = num_steps * time_step.value_in_unit(unit.picoseconds) * 1e-3
total_time_in_days = total_time / (86400)
ns_per_day = simulation_in_ns / total_time_in_days

dG = meta.getFreeEnergy()
print("dG:")
print(dG)
#print("Host-1-butanol system benchmark:", ns_per_day, "ns/day")
print("TTK system benchmark:", ns_per_day, "ns/day")

dG = dG - np.min(dG)

dG_filename = "dG_1fvaq_metaD.txt"
print("Saving metadynamics dG to:", dG_filename)
np.savetxt(dG_filename, dG)

p = plt.imshow(dG, extent=[0.0, 2.0, 0.0, 2.0], cmap=plt.cm.jet, origin="lower")
plt.title("Metadynamics Free Energy Plot")
plt.xlabel("com-com distance: CV1 (nm)")
plt.ylabel("iso distance: CV2 (nm)")
cbar = plt.colorbar(p)
cbar.set_label("Energy (kJ/mol)")
#plt.show()
plot_filename = "metaD_1fvaq.png"
print(f"saving plot to {plot_filename}")
plt.savefig(plot_filename)
