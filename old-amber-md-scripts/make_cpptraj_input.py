import shutil
import os
import glob

pdb_path = 'pdbs' #path to directory with pdbs to combine
pdb_file = os.listdir(pdb_path) #create a list of all pdbs in directory
input_script = 'input_script.in' #name of input script
topology_file = '.prmtop' #name of prmtop file

with open('input_script.in','w') as file:

    #cpptraj command to load topology file
    parm = topology_file + ' \n'
    file.write(parm)

    #iterate over pdb files in directory
    for pdb in pdb_file:        
        #command to load trajectory
        trajin = 'trajin ' +pdb_path+ '/' + pdb + '\n'
        file.write(trajin)

    #command to align structures
    file.write('align first \n')

    #command to write combined pdb file
    trajout = 'trajout combined_povme.pdb \n'
    file.write(trajout)

    file.close()

#write script to load amber and run cpptraj
with open('run_cpptraj.sh','w') as file:
    file.write('#!/bin/bash \n')
    file.write('module load amber \n')
    file.write('cpptraj -i ' + input_script)
    file.close()

