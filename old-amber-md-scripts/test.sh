#!/bin/bash
SYSPATH='/net/gpfs-amarolab/jsanlleyhernandez/mpro_md/mpro_'$1/4*/
for FILE in $SYSPATH
do 
	cat $FILE/*summary*
done
 
