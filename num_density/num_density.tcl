#!/bin/tclsh
#

if {1} {
	set outputW [open "numden.wat" "w"]
	set outputNA [open "numden.na" "w"]
	set outputCL [open "numden.cl" "w"]

	set num_frames_total 0
	set maxdist 15
	set distincr 1

	set fstep 100
}

# get the geometry center
proc getCOM {sel_str i} {
	set sel [atomselect top $sel_str frame $i]
	set com [measure center $sel]
	return $com
}

# get the serial number within specified dist
# the maxdist is specified by arg $maxdist
proc getXYZ {sel_str i} {
	global maxdist
	set sel [atomselect top ${sel_str} frame $i]
	return [$sel get {x y z}]
}

# calculate the distance formed between two points
proc caldist {coor1 coor2} {
	set vec [vecsub $coor1 $coor2]
	set vecl [veclength $vec]

	return $vecl
}

proc countNUM {COM wlist maxdist distincr} {
	set results {}
	for {set dist 0} {${dist} < ${maxdist}} {incr dist ${distincr}} {
		set count 0
		set ldist $dist
		set rdist [expr $dist + $distincr]
		foreach w $wlist {
			set d [caldist $COM $w]

			if {${d} >= ${ldist} && ${d} < ${rdist}} {
				set count [expr ${count} +1 ]
			}
		}
		lappend results $count
	}

	return $results
}


foreach filename ${argv} {
	global maxdist
	global distincr

	animate delete all
	mol addfile ${filename} waitfor all
	set frames [molinfo top get numframes]

	set selstr_kn "resname LYS"
	set selw "name W and same residue as within $maxdist of resname LYS"
	set selna "name NA and same residue as within $maxdist of resname LYS"
	set selcl "name CL and same residue as within $maxdist of resname LYS"

	for {set i 0} {${i} < ${frames}} {incr i $fstep} {
		set frame [expr ${num_frames_total} + ${i} +1]
		
		pbc wrap -center com -centersel $selstr_kn -first ${i} -last ${i}

		set com [getCOM $selstr_kn $i]

		set wLIST [getXYZ $selw $i]
		set naLIST [getXYZ $selna $i]
		set clLIST [getXYZ $selcl $i]

		set resultsW [countNUM $com $wLIST $maxdist $distincr]
		set resultsNA [countNUM $com $naLIST $maxdist $distincr]
		set resultsCL [countNUM $com $clLIST $maxdist $distincr]

		puts -nonewline ${outputW} [format "%10d" $frame]
		foreach wat $resultsW {
			put -nonewline ${outputW} [format "%4d" $wat]
		}
		put ${outputW} [format "%1s" " "]


		puts -nonewline ${outputNA} [format "%10d" $frame]
		foreach na $resultsNA {
			put -nonewline ${outputNA} [format "%4d" $na]
		}
		put ${outputNA} [format "%1s" " "]


		puts -nonewline ${outputCL} [format "%10d" $frame]
		foreach cl $resultsCL {
			put -nonewline ${outputCL} [format "%4d" $cl]
		}
		put ${outputCL} [format "%1s" " "]
	
	}


	set num_frames_total [expr ${num_frames_total} + ${frames}]
}

quit
