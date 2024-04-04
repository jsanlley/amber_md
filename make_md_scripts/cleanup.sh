#Make cleanup file to sort files into directories and also make replica files

#prod
	#1,2,3
		#copy to production file (prmtop,equil.rst,prod script)
		#copy replica files

#equil
	#equilibration files

#heat
	#heating files

#min
	#min files

#prep
	#tleap files	

#parm

cat > cleanup.sh << EOF
#!/bin/bash

mkdir prod

mkdir prod/1
mv prod.mdin prod/1
cp *prmtop prod/1
cp *_equil.rst prod/1

cp -r prod/1 prod/2
cp -r prod/2 prod/3

mv *_1.slurm prod/1
mv *_2.slurm prod/2
mv *_3.slurm prod/3


mkdir prep
mkdir prep/min
mv *min* prep/min

mkdir prep/heat
mv *heat* prep/heat

mkdir prep/equil
mv *equil* prep/equil

mkdir parm
mkdir parm/antechamber
mv *antechamber* parm/antechamber
mv *A* parm/antechamber
mv sqm* parm/antechamber
mv 7YY* parm

mkdir parm/tleap
mv *leap* parm/tleap
mv *solvated* parm/tleap

rm cleanup.sh
EOF

. cleanup.sh
