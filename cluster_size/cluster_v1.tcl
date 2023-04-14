#!/bin/tclsh

lappend auto_path ./la1.0
lappend auto_path ./orient

package require pbctools
package require Orient
namespace import Orient::orient

if {1} {
	set output [open "cluster.dat" "w"]
	set fstep 5
	# total num of KN is set to be 20
	set K_num 20
	# analyzing system K8
	set Kn 8
	set CG_resolution 3
	set c_cutoff 8
	set num_frames_total 0
	set K_total [expr {${K_num} * ${Kn} * ${CG_resolution}}]
	set MAX_CYC 20

	set clu_list_summary {}
	for {set i 0} {$i < ${K_num}} {incr i} {
		lappend clu_list_summary {}
	}
}

proc get_resi {curr_resi i} {
	global Kn
	global CG_resolution
	global c_cutoff

	set s_tmp {}
	set idx_s [expr {${curr_resi} * ${Kn} * ${CG_resolution} +1}]
	set idx_e [expr {[expr {${curr_resi}+1}] * ${Kn} * ${CG_resolution}}]
	set sel_str "serial $idx_s to $idx_e"
	set sel_tmp [atomselect top "${sel_str}" frame ${i}]
	pbc wrap -center com -centersel $sel_str -first ${i} -last ${i}
	set sel_cutoff [atomselect top "(resname LYS and same residue as within ${c_cutoff} of $sel_str) and (not $sel_str)" frame ${i}]
	set sel_cutoff_serial [$sel_cutoff get serial]

	if {[llength $sel_cutoff_serial] !=0} {
		# convert serial to residue num 0,1,2,...,19
		foreach item ${sel_cutoff_serial} {
			set tmp [expr {($item-1) / (${Kn} * ${CG_resolution})}]
			if {[lsearch $s_tmp $tmp] <0} {
				lappend s_tmp $tmp
			}
		}
	}

	$sel_tmp delete
	$sel_cutoff delete
	return $s_tmp
}

proc l_remove {ll item} {
	set idx [lsearch $ll $item]
	set result [lreplace $ll $idx $idx]
	return $result
}

proc get_max_elem_length {ll} {
	set max_l 0
	foreach item ${ll} {
		set l_tmp [llength $item]
		if {$l_tmp > $max_l} {
			set max_l ${l_tmp}
		}
	}

	return $max_l
}

proc size_ratio {ll i} {
	global Kn
	global CG_resolution
	global c_cutoff
	# find the list with the largest cluster
	set max_l 0
	foreach item ${ll} {
		set l_tmp [llength $item]
		if {${l_tmp} > $max_l} {
			set max_l ${l_tmp}
			set max_list ${item}
		}
	}

	set sel_serial_str {}
	foreach item ${max_list} {
		for {set i [expr {${item} * $Kn * $CG_resolution}]} {${i} < [expr {(${item}+1) * $Kn * $CG_resolution}]} {incr i} {
			lappend sel_serial_str [expr {$i +1}]
		}
	}

	set sel [atomselect top "resname LYS and serial $sel_serial_str" frame $i]
	pbc wrap -center com -centersel "resname LYS and serial ${sel_serial_str}" -first ${i} -last ${i}

	set I [draw principalaxes ${sel}]
	# orient $sel to axies {0 0 1}
	set A [orient $sel [lindex ${I} 2] {0 0 1}] 
	$sel move $A

	set minmax [measure minmax $sel]
	set vec [vecsub [lindex $minmax 0] [lindex $minmax 1]]

	set min_v 10000
	set max_v 0
	foreach vec_item $vec {
		set tmp_v [expr {abs(${vec_item})}]
		if {${tmp_v} > ${max_v}} {
			set max_v $tmp_v
		}
		if {${tmp_v} < ${min_v}} {
			set min_v $tmp_v
		}
	}		

	set ld_ratio [expr {${max_v} / ${min_v}}]

	return ${ld_ratio}

}




foreach filename ${argv} {
	animate delete all
	mol addfile ${filename} waitfor all
	set frames [molinfo top get numframes]
	#puts "total num frames: ${frames}"
	for {set i 0} {${i} < ${frames}} {incr i $fstep} {
		set frame [expr ${num_frames_total} + ${i} +1]

		# construct a list to store the total res idx
		# starting from 0 to ${K_num}
		set c_list_unassign {}
		for {set selx 0} {$selx < ${K_num}} {incr selx} {
			lappend c_list_unassign $selx
		}

		# storing assigned res idx
		set c_list_assigned {}
		# storing cluster info
		set clu_list {}
		# storing
		set c_length {}
		# counting cluster number
		set c_counter 0

		set s_cut_ {}

		for {set seli 0} {$seli < ${K_num}} {incr seli} {
			set s_tmp {}
			#puts "Kn index: ${seli}"	
			set has_comm [lsearch ${c_list_unassign} ${seli}]
			if {${has_comm} >= 0 } {
				lappend s_tmp ${seli}
				# append resid to list_assigned
				lappend c_list_assigned ${seli}
				# delete resid from list_unassign
				set c_list_unassign [l_remove ${c_list_unassign} ${seli}]
				#set idx [lsearch $c_list_unassign ${seli}]
				#set c_list_unassign [lreplace $c_list_unassign ${idx} ${idx}]

				set curr_resi $seli
				set adj_res [get_resi ${curr_resi} ${i}]

				#for item $adj_res {
				#	lappend c_list_assigned $item
				#	set c_list_unassign [l_remove ${c_list_unassign} $item]
				#}

				puts "adj_res: $adj_res"
				#puts "unassign: ${c_list_unassign}"

				if {[llength $adj_res] ==0} {
					set c_counter [expr {$c_counter +1}]
					#puts "Frame ${i} s_tmp: ${s_tmp}"
					lappend clu_list ${s_tmp}
				} else {
					set tmp_adj {}
					for {set cyc_i 0} {${cyc_i} < ${MAX_CYC}} {incr cyc_i} {
						set l_tmp_adj_s [llength $tmp_adj]
						foreach x $adj_res {
							if {[lsearch $s_tmp ${x}] <0} {
								lappend s_tmp ${x}
							}
							if {[lsearch $c_list_assigned ${x}] <0} {
								lappend c_list_assigned ${x}
								set c_list_unassign [l_remove ${c_list_unassign} ${x}]
							}

							set curr_resi $x
							set adj_res_tmp [get_resi ${curr_resi} ${i}]
							
							foreach adj_res_tmp_x $adj_res_tmp {
								if {[lsearch $s_tmp $adj_res_tmp_x] < 0} {
									lappend tmp_adj $adj_res_tmp_x
								}
							}

							#set tmp_adj [concat $tmp_adj $adj_res_tmp]
						}
						set l_tmp_adj_e [llength $tmp_adj]
						#puts "seli ${seli} | tmp_adj ${tmp_adj} "
						if {$l_tmp_adj_s != $l_tmp_adj_e} {
							# means find adj residue
							set adj_res [lsort -unique ${tmp_adj}]
						} else {
							set c_counter [expr {${c_counter} +1}]
							lappend clu_list ${s_tmp}
							break
						}
					}
				}

			}
		}
		
		#puts "Cluster list: ${clu_list}"
		puts -nonewline ${output} [format "%10d" $frame]
		puts -nonewline ${output} [format "%10d" $c_counter]
		puts -nonewline ${output} [format "%10d" [get_max_elem_length $clu_list]]
		puts ${output} [format "%10.5f" [size_ratio $clu_list $i]]
		#puts -nonewline ${output} [format "%10d" [get_max_elem_length $clu_list]]
		#puts ${output} ${clu_list}

	}

	set num_frames_total [expr ${num_frames_total} + ${frames}]
}

quit
