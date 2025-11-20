#!/bin/bash

# Load module
module load schrodinger/2024u1

# Define pd file name and output pdb file name
FILE_NAME="Final_model"
OUTPUT_NAME="Final_model"

# Convert back maestro file to pdb file
"${SCHRODINGER}/utilities/structconvert" maestro/${FILE_NAME}_prepared.mae maestro/${OUTPUT_NAME}_prepared.pdb

# Rename histidines accordingly HIS to HID, remove additional fragments
#sed -i 's/HIS B  41/HID B  41/g' maestro/${OUTPUT_NAME}_prepared.pdb
#sed -i 's/HIS B  64/HID B  64/g' maestro/${OUTPUT_NAME}_prepared.pdb
#sed -i 's/HIS B  80/HIE B  80/g' maestro/${OUTPUT_NAME}_prepared.pdb
#sed -i 's/HIS B 163/HID B 163/g' maestro/${OUTPUT_NAME}_prepared.pdb
#sed -i 's/HIS B 164/HID B 164/g' maestro/${OUTPUT_NAME}_prepared.pdb
#sed -i 's/HIS B 172/HIE B 172/g' maestro/${OUTPUT_NAME}_prepared.pdb
#sed -i 's/HIS B 246/HIE B 246/g' maestro/${OUTPUT_NAME}_prepared.pdb

# Run pdb4amber to get the right protonation states
module load amber
pdb4amber -i maestro/${OUTPUT_NAME}_prepared.pdb -o maestro/${OUTPUT_NAME}_prepared_pdb4a.pdb

# Copy back output pdb file to pdb directory
cp maestro/${OUTPUT_NAME}_prepared_pdb4a.pdb ${OUTPUT_NAME}_prepared.pdb

