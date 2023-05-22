#!/bin/tclsh

package require pbctools

if {1} {
	set output [open "dipole_orient.dat" "w"]
	set fstep 5
	# total num of KN is set to be 20
	set K_num 20
	# analyzing system K4
	set Kn 40
	set PI 3.1415926
	set CG_resolution 3
	set num_frames_total 0
	set K_total [expr {${K_num} * ${Kn} * ${CG_resolution}}]
}

proc angle_ {dipole axis} {
	global PI

	if {$axis=="Z"} {
		set vec {0 0 1}
	} elseif {$axis == "X"} {
		set vec {1 0 0}
	} else {
		set vec {0 1 0}
	}

	set lZ [veclength $vec]
	set lDip [veclength $dipole]
	set dot_v [vecdot $dipole $vec]

	set cos_theta [expr $dot_v / ($lZ * $lDip)]

	set theta [expr acos($cos_theta)*180/$PI]
	return $theta
}



foreach filename ${argv} {
	animate delete all
	mol addfile ${filename} waitfor all
	set frames [molinfo top get numframes]

	for {set i 0} {${i} < ${frames}} {incr i ${fstep}} {
		set frame [expr ${num_frames_total} + ${i} +1]


		# loop through num of KN
		set dipole_angle {}
		for {set seli 0} {$seli < ${K_num}} {incr seli} {

			puts -nonewline ${output} [format "%6d" $frame]
			puts -nonewline ${output} [format "%3d" $seli]

			set idx_s [expr $seli * ${Kn} * ${CG_resolution} +1]
			set idx_e [expr [expr $seli +1] * ${Kn} * ${CG_resolution}]

			set sel_str "serial $idx_s to $idx_e"
			set sel [atomselect top $sel_str frame $i]

	
			set dipole [measure dipole $sel]

			#puts $dipole

			set dipole_angle_X [angle_ $dipole "X"]
			set dipole_angle_Y [angle_ $dipole "Y"]
			set dipole_angle_Z [angle_ $dipole "Z"]

			#lappend dipole_angle $dipole_angle_tmp
		
			puts -nonewline ${output} [format "%8.2f" $dipole_angle_X]
			puts -nonewline ${output} [format "%8.2f" $dipole_angle_Y]
			puts ${output} [format "%8.2f" $dipole_angle_Z]

			$sel delete
		}
		#puts ${output} [format "%1s" " "]
	
	}

	set num_frames_total [expr ${num_frames_total} + ${frames}]

}

quit
