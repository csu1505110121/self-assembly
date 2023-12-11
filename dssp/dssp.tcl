#!/bin/tclsh

package require pbctools

if {1} {
	set output [open "dssp.dat" "w"]
	set fstep 5
	# total num of KN is set to be 20
	set K_num 20
	# analyzing system K4
	set Kn 4
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

proc selectDihed {curr_Kn curr_resi} {
	# select 4 atoms for calculating corresponding
	# dihedral
	global Kn
	global CG_resolution

	set psi_idx_1 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + [expr ${curr_resi} -1]* ${CG_resolution} +1}]
	set psi_idx_2 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + [expr ${curr_resi} -1] * ${CG_resolution} }]
	set psi_idx_3 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + ${curr_resi} * ${CG_resolution}}]
	set psi_idx_4 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + ${curr_resi} * ${CG_resolution} +1}]

	set phi_idx_1 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + ${curr_resi} * ${CG_resolution} +1}]
	set phi_idx_2 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + ${curr_resi} * ${CG_resolution}}]
	set phi_idx_3 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + [expr ${curr_resi} +1] * ${CG_resolution}}]
	set phi_idx_4 [expr {${curr_Kn} * ${Kn} * ${CG_resolution} + [expr ${curr_resi} +1] * ${CG_resolution} +1}]
	
	set psi [list $psi_idx_1 $psi_idx_2 $psi_idx_3 $psi_idx_4]
	set phi [list $phi_idx_1 $phi_idx_2 $phi_idx_3 $phi_idx_4]

	return [list $psi $phi]
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
			# starting from 1 and ending at Kn -1
			# since starting and ending resiude could not
			# form dihed
			for {set selres 1} {${selres} < [expr ${Kn} -1]} {incr selres} {
				set dihidx [selectDihed $curr_resi $selres]
				#puts -nonewline $curr_resi
				#puts -nonewline "\t"
				#puts -nonewline $selres
				#puts -nonewline "\t"
				#puts -nonewline [lindex $dihidx 0]
				#puts -nonewline "\t"
				#puts [lindex $dihidx 1]
				##puts $curr_resi $selres [lindex $dihidx 0] [lindex $dihidx 1]
				set psi_idx [lindex $dihidx 0]
				set phi_idx [lindex $dihidx 1]

				set psi [measure dihed $psi_idx frame $i]
				set phi [measure dihed $phi_idx frame $i]
				
				puts -nonewline ${output} [format "%10d" $frame]
				puts -nonewline ${output} [format "%5d" $curr_resi]
				puts -nonewline ${output} [format "%5d" $selres]
				puts -nonewline ${output} [format "%10.2f" $psi]
				put ${output} [format "%10.2f" $phi]
			}
		}

	}
set num_frames_total [expr ${num_frames_total} + ${frames}]
}

quit

