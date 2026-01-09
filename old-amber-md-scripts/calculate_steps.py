import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-t','--time',help='Simulation time in ns')
args = parser.parse_args()

time = float(args.time)
dt = 0.002
steps = int((time*1000)/dt)
ns_frame = (time*1000)/steps
print("System description")
print("Simulation time: " + str(time) + " ns")
print("Total number of steps: " + str(steps) + " steps")
print("Time between frames: " +str(ns_frame) + " ps") 

