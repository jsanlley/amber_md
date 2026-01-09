# From terminal: vmd -dispdev text -e script.tcl
# From vmd (tkconsole or terminal window): source script.tcl

set pathway "/net/gpfs-amarolab/jsanlleyhernandez/mpro_md"
set centroids {0 1 2}
set mol_ids {0 1 2 3 4 5}
set names {mpro_nirm mpro_F2459-2036 mpro_1733 mpro_nirm mpro_F2459-2036 mpro_1733}

foreach id $mol_ids n $names {
        foreach c $centroids {
                if {$c == 0} {set command "new"} else {set command "addfile"}
                # Add centroids for chain A
                puts " Working on centroid $c of $n"
                if   {($n == "mpro_F2459-2036") && ($id <3)} {set reschain "611B";mol $command $pathway/$n/4-analysis/${n}_${reschain}_kmeans_rep.c$c.pdb type pdb waitfor all}
                if   {($n != "mpro_F2459-2036") && ($id <3)} {set reschain "611A";mol $command $pathway/$n/4-analysis/${n}_${reschain}_kmeans_rep.c$c.pdb type pdb waitfor all}
                if   {($n == "mpro_F2459-2036") && ($id >2)} {set reschain "612A";mol $command $pathway/$n/4-analysis/${n}_${reschain}_kmeans_rep.c$c.pdb type pdb waitfor all}
                if   {($n != "mpro_F2459-2036") && ($id >2)} {set reschain "612B";mol $command $pathway/$n/4-analysis/${n}_${reschain}_kmeans_rep.c$c.pdb type pdb waitfor all}
        }
        puts " Centroids for molid $id named \"$n\" loaded"
}
