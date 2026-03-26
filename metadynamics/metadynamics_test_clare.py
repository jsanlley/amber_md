"""
This script uses metadynamics to dissociate a two-protein complex.
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


prmtop_filename = "solvated_bar_neutral.prmtop"
pdb_filename = "equilibrated_imaged.pdb"

prmtop = app.AmberPrmtopFile(prmtop_filename)
mypdb = app.PDBFile(pdb_filename) # get equilibrated pdb from struct with CRYST line at the top

kcal_per_mole = unit.kilocalories / unit.mole
kJ_per_mol = unit.kilojoules / unit.mole

#change to mpro
com_indices1 = [] # protein com active site
com_indices2 = [] # ens heavy atoms w/o H atoms

# box dims 
box_vectors = parmed.load_file(pdb_filename).box_vectors
box_vectors_nm = box_vectors.value_in_unit(parmed.unit.nanometers)


temperature = 310*unit.kelvin
cuda_device_index = "0"
nonbonded_cutoff = 0.9*unit.nanometer

# time step of simulation 
time_step = 0.002 * unit.picoseconds

#optionally print a trajectory (WORK FROM TRAJ INSTEAD OF PDB)
trajectory_filename = "metadyn_bb_trajectory_test_clare.nc" # output pdb with multiple trajs (double check with seekr script)
trajectory_interval = 25000 #change to every 250ps, double check

# total number of timesteps to take in the metadynamics simulation (do 50ns short simulation to test)
num_steps = 500000 # 60 ns (200 ns = 50000000, 20000000 default)

#metadynamics parameters (change to/check with HIDR parameters)
npoints = 181 #Can be left blank and a value will be assigned by openmm
sigma = 0.05 * unit.nanometers #(0.05 default)
nsteps = 250 #(250 default)
height = 1.0 * kJ_per_mol
biasFactor = 10.0 #the well-tempered metadynamics bias factor. Increase to infinity for standard metadynamics, 0 for standard MD



system = prmtop.createSystem(
    nonbondedMethod=app.PME, 
    nonbondedCutoff=nonbonded_cutoff, 
    constraints=app.HBonds)


# Keep the system from escaping out too far (change to closer)
barrier_distance = 2.0 * unit.nanometer # double check with unbinding (stay within as boundary)
barrier_spring_constant = 9000.0 * unit.kilojoules_per_mole * unit.nanometers**2
barrier_force = openmm.CustomCentroidBondForce(2, "0.5*k*step(distance(g1, g2) - radius)*(distance(g1, g2) - radius)^2")
barrier_group1a = barrier_force.addGroup(com_indices1)
barrier_group2a = barrier_force.addGroup(com_indices2)
barrier_force.setForceGroup(1)
barrier_force.addPerBondParameter("k")
barrier_force.addPerBondParameter("radius")
barrier_force.addBond([barrier_group1a, barrier_group2a], [barrier_spring_constant, barrier_distance])
barrier_forcenum = system.addForce(barrier_force)


myforce1 = openmm.CustomCentroidBondForce(2, "distance(g1, g2)")
mygroup1a = myforce1.addGroup(com_indices1)
mygroup1b = myforce1.addGroup(com_indices2)
myforce1.addBond([mygroup1a, mygroup1b], [])

myforce1_bias = app.BiasVariable(
    myforce1, 
    minValue=0.0*unit.nanometers, # for protein-protein do ~2.5 (respect distance bt proteins such as hbonds)
    maxValue=6.0*unit.nanometers,
    biasWidth=sigma, 
    periodic=False, 
    gridWidth=npoints)

# double check in doc
meta = app.Metadynamics(
    system, 
    variables=[myforce1_bias], 
    temperature=temperature,
    biasFactor=biasFactor, 
    height=height, 
    frequency=nsteps,
    biasDir="bias", 
    saveFrequency=nsteps)

integrator = openmm.LangevinIntegrator(temperature, 1/unit.picosecond, time_step)
platform = openmm.Platform.getPlatformByName("CUDA")
properties = {"CudaDeviceIndex": cuda_device_index, "CudaPrecision": "mixed"}
simulation = app.Simulation(prmtop.topology, system, integrator, platform, properties)

#if inpcrd.boxVectors is not None:
#    simulation.context.setPeriodicBoxVectors(*inpcrd.boxVectors)

simulation.context.setPeriodicBoxVectors(*box_vectors_nm)

simulation.context.setPositions(mypdb.positions)
simulation.context.setVelocitiesToTemperature(temperature)
simulation.minimizeEnergy()

simulation.reporters.append(app.StateDataReporter(stdout, 1000, step=True, potentialEnergy=True, temperature=True,))

if trajectory_filename and trajectory_interval:
    dcd_reporter = app.DCDReporter(trajectory_filename, trajectory_interval)
    simulation.reporters.append(dcd_reporter)

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
print("BB metaD benchmark:", ns_per_day, "ns/day")

dG = dG - np.min(dG)
dG_filename = "dG_metaD_output.txt"
print("Saving metadynamics dG to:", dG_filename)
np.savetxt(dG_filename, dG)
