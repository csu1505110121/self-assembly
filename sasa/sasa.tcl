#!/bin/tclsh

if {1} {
	set output1 [open "sasa.dat" "w"]
	set num_frames_total 0
}

foreach filename ${argv} {
	animate delete all
	mol addfile $filename waitfor all
	set frames [molinfo top get numframes]
	for {set i 0} {${i} < ${frames}} {incr i} {
		set frame [expr ${num_frames_total} + ${i} +1]

		set sel [atomselect top "resname LYS" frame ${i}]
		set v_sasa [measure sasa 1.4 ${sel}]
		puts -nonewline ${output1} [format "%20d " $frame ]
		puts ${output1} [format "%10.5f" ${v_sasa}]
		$sel delete
	}
	set num_frames_total [expr ${num_frames_total} + ${frames}]
}


quit
