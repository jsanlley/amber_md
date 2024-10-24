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

cat > undo_cleanup.sh << EOF
#!/bin/bash

mv prod/1/* .
mv prep/*/* .
mv parm/*/* .
rm -r parm/antechamber
rm -r parm/tleap 
mv parm/* .

rm undo_cleanup.sh
EOF

. undo_cleanup.sh
