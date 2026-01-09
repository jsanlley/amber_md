import time
import simtk.openmm.app as app
import simtk.openmm as mm
import simtk.unit as unit
from sys import stdout
import parmed
import numpy as np

#########################
# MODIFY THESE VARIABLES
#########################

# These are the files produced by the LEAP script
prmtop_filename = "5n84.prmtop"
inpcrd_filename = "5n84.inpcrd"
input_pdb_file = "5n84_after_leap.pdb"

# Output equilibration trajectory
trajectory_filename = "5N84_equilibration_trajectory.pdb"

# The interval between updates to the equilibration trajectory
steps_per_trajectory_update = 300000

# Final structure output
output_pdb_file = "equilibrated.pdb"

# Whether to minimize
minimize = True

# The total number of equilibration MD steps to take
num_steps = 30000000 # 60 nanoseconds

# The interval between energy printed to standard output
steps_per_energy_update = 5000

# time step of simulation 
time_step = 0.002 * unit.picoseconds

# simulation initial and target temperature
temperature = 310*unit.kelvin

# If constant pressure is desired
constant_pressure = True
target_pressure = 1.0*unit.bar

# Define which GPU to use
cuda_index = "0"

# Nonbonded cutoff
nonbonded_cutoff = 0.9*unit.nanometer

########################################################
# DO NOT MODIFY BELOW UNLESS YOU KNOW WHAT YOU'RE DOING
########################################################

tmp_prmtop_filename = "molecule_TMP.prmtop"
tmp_inpcrd_filename = "molecule_TMP.inpcrd"
inpcrd_final = "equilibrated.rst7"

# parmed can process the prmtop/inpcrd to get ready for OpenMM
amber_parm = parmed.amber.AmberParm(prmtop_filename, inpcrd_filename)
#amber_parm.save(tmp_prmtop_filename, overwrite=True)
#amber_parm.save(tmp_inpcrd_filename, overwrite=True)

#prmtop = app.AmberPrmtopFile(tmp_prmtop_filename)
#inpcrd = app.AmberInpcrdFile(tmp_inpcrd_filename)
prmtop = app.AmberPrmtopFile(prmtop_filename)
inpcrd = app.AmberInpcrdFile(inpcrd_filename)
mypdb = app.PDBFile(input_pdb_file)
system = prmtop.createSystem(nonbondedMethod=app.PME, nonbondedCutoff=nonbonded_cutoff,
        constraints=app.HBonds)

if constant_pressure:
    barostat = mm.MonteCarloBarostat(target_pressure, temperature, 25)
    system.addForce(barostat)
integrator = mm.LangevinIntegrator(temperature, 1/unit.picosecond, time_step)
platform = mm.Platform.getPlatformByName('CUDA')
properties = {"CudaDeviceIndex": cuda_index, "CudaPrecision": "mixed"}
simulation = app.Simulation(prmtop.topology, system, integrator, platform, properties)
simulation.context.setPositions(mypdb.positions)
simulation.context.setPeriodicBoxVectors(*inpcrd.boxVectors)
if minimize:
    simulation.minimizeEnergy()
simulation.context.setVelocitiesToTemperature(temperature)
simulation.reporters.append(app.StateDataReporter(stdout, steps_per_energy_update, step=True,
            potentialEnergy=True, temperature=True, volume=True))
pdb_reporter = app.PDBReporter(trajectory_filename, steps_per_trajectory_update)
simulation.reporters.append(pdb_reporter)
start_time = time.time()
simulation.step(num_steps)
total_time = time.time() - start_time

state = simulation.context.getState(getPositions = True, getVelocities = True, enforcePeriodicBox = True)
positions = state.getPositions()
amber_parm = parmed.amber.AmberParm(prmtop_filename, inpcrd_filename)
amber_parm.positions = positions
amber_parm.box_vectors = state.getPeriodicBoxVectors()
amber_parm.save(inpcrd_final, overwrite=True)
amber_parm.save(output_pdb_file, overwrite=True)

