#!/bin/bash

# IMPORTANT: make sure .mc file is defined appropriately

# Go to antechamber directory and run script
cd parm/antechamber
. run_parm.sh
wait

# Go to tleap directory and run script
cd ../tleap
tleap -f parm_tleap_customaa.in 
