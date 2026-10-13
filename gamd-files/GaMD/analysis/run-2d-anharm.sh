#!/bin/sh
cd ~/GaMD/analysis
chmod +x create-2d-anharmonicity.sh
#gamd 1D
./create-2d-anharmonicity.sh Phi_all.dat Psi_all.dat gamd-all.log
