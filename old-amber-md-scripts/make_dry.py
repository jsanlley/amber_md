import os
import glob

path = '/net/gpfs-amarolab/jsanlleyhernandez/mpro_md'
systems = ['nirm','1733','1819']
pdb_list = []

for system in systems:
    pdb_path = glob.glob(path+'/mpro_'+system+'/2*/*solvated.pdb')
    
    for pdb in pdb_path:
        pdb_list.append(pdb)

print(pdb_list)
print(len(pdb_path))
