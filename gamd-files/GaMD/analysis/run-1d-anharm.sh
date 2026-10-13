#!/bin/sh
cd ~/GaMD/analysis
chmod +x create-1d-anharmonicity.sh
#gamd 1D
./create-1d-anharmonicity.sh Psi_all.dat gamd-all.log
