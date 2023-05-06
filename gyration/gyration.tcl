#!/bin/tclsh
# make sure the trajectory utilized are wrapped ones
#                    Created by Qiang @UCI
if {1} {
	set output [open "gyration.dat" "w"]
	set fstep 5

	# total num of KN is set to be 20
	set K_num 20
	# analyzing system K8
	set Kn 40
	set CG_resolution 3

	set num_frames_total 0
	set K_total [expr {${K_num} * ${Kn} * ${CG_resolution}}]
}

proc average {l} {
	set sum 0
	foreach x $l {
		set sum [expr $sum + $x]
	}

	return [expr $sum / [llength $l]]
}

proc std {l} {
	set std 0
	set ave [average $l]
	foreach x $l {
		set std_tmp [expr ($x - $ave)**2]
		set std [expr $std + $std_tmp]
	}

	return [expr sqrt($std / [llength $l])]
}

proc selectATM {curr_resi} {
	global Kn
	global CG_resolution
	
	set idx_s [expr {${curr_resi} * ${Kn} * ${CG_resolution} +1}]
	set idx_e [expr {[expr {${curr_resi}+1}] * ${Kn} * ${CG_resolution}}]

	set sel_str "serial ${idx_s} to ${idx_e}"
	return $sel_str
}


set total_results {}

foreach filename ${argv} {
	animate delete all
	mol addfile ${filename} waitfor all
	set frames [molinfo top get numframes]

	for {set i 0} {${i} < ${frames}} {incr i ${fstep}} {
		set frame [expr ${num_frames_total} + ${i} +1]
		
		for {set seli 0} {${seli} < ${K_num}} {incr seli} {
			set curr_resi ${seli}
			set str_sel [selectATM ${curr_resi}]
			set sel [atomselect top ${str_sel} frame $i]
			set rg [measure rgyr $sel]
			lappend total_results $rg 
			$sel delete
		}
	}
set num_frames_total [expr ${num_frames_total} + ${frames}]
}

#puts ${total_results}
#puts [llength ${total_results}]

set v_ave [average ${total_results}]
set v_std [std ${total_results}]

puts -nonewline ${output} [format "%10.5f" $v_ave]
puts ${output} [format "%10.5f" $v_std]


quit

