#!/bin/tclsh

# make sure the trajectory utilized are wrapped ones
if {1} {
	set output [open "order.dat" "w"]
	set fstep 5

	# total num of KN is set to be 20
	set K_num 20
	# analyzing system K8
	set Kn 4
	set CG_resolution 3

	set PI 3.1415926

	set num_frames_total 0
	set K_total [expr {${K_num} * ${Kn} * ${CG_resolution}}]
}

# curr_resi: the ith Kn
# i: frame i
# get the serial of backbone
proc get_BB {curr_resi i} {
	set results {}
	global Kn
	global CG_resolution 

	set idx_s [expr {${curr_resi} * ${Kn} * ${CG_resolution} +1}]
	set idx_e [expr {[expr {${curr_resi}+1}] * ${Kn} * ${CG_resolution}}]
	set sel_str "serial $idx_s to $idx_e"
	set sel_tmp [atomselect top "$sel_str and name BB" frame ${i}]
	set BB_serial [$sel_tmp get serial]
	set BB_xyz [$sel_tmp get {x y z}]

	lappend results $BB_serial
	lappend results $BB_xyz

	$sel_tmp delete
	return ${results}
}

proc cal_Angle {a b c} {
	global PI
	set v1 [vecsub $a $b]
	set v2 [vecsub $c $b]
	
	set dot_v [vecdot $v1 $v2]
	set len_v1 [veclength $v1]
	set len_v2 [veclength $v2]

	set cos_theta [expr $dot_v / ($len_v1 * $len_v2)]

	set theta [expr acos($cos_theta)*180/${PI}]

	return $theta 
}

proc get_Angle {bb_list} {
	set angle_list {}
	set llist [llength $bb_list]
	for {set i 0} {${i} < $llist} {incr i} {
		if {$i != 0 && $i != [expr $llist -1]} {
			set n_l [expr ${i} -1]
			set n_r [expr ${i} +1]

			set v_a [lindex ${bb_list} $n_l]
			set v_b [lindex ${bb_list} ${i}]
			set v_c [lindex ${bb_list} $n_r]

			set theta [cal_Angle $v_a $v_b $v_c]
			lappend angle_list $theta
		}
	
	}
	return $angle_list 
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

set total_results {}

foreach filename ${argv} {
	animate delete all
	mol addfile ${filename} waitfor all
	set frames [molinfo top get numframes]

	for {set i 0} {${i} < ${frames}} {incr i ${fstep}} {
		set frame [expr ${num_frames_total} + ${i} +1]


		for {set seli 0} {$seli < ${K_num}} {incr seli} {
			set curr_resi $seli
			# get the BackBone serial we selected
			#set BB [get_BB $curr_resi $i]
			set BB_ [lindex [get_BB $curr_resi $i] 0]
			set BB_xyz [lindex [get_BB $curr_resi $i] 1]
			#puts "${frame} ${seli} [llength ${BB_xyz}]"

			set ANGLE [get_Angle $BB_xyz]

			#puts "${frame} ${seli} ${ANGLE}"
			lappend total_results $ANGLE
		}
	}

	set num_frames_total [expr ${num_frames_total} + ${frames}]
}

for {set k 0} {${k} < [llength [lindex $total_results 0]]} {incr k} {
	set tmp_angle {}
	foreach angles $total_results {
		lappend tmp_angle [lindex $angles $k]
	}

	puts -nonewline ${output} [format "%5d" $k]
	puts -nonewline ${output} [format "%8.2f" [average $tmp_angle]]
	puts ${output} [format "%8.2f" [std $tmp_angle]]

}

quit
