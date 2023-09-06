#!/bin/tclsh

if {1} {
	set output [open "rmsf.dat" "w"]
	#set output1 [open "rmsd.test.dat" "w"]
	set K_num 20
	# analyzing system K4
	set refFILE ../../model_construct/k40_atp_conc.gro
	set Kn 40
	set CG_resolution 3
	set num_frames_total 0
	set K_total [expr {${K_num} * ${Kn} * ${CG_resolution}}]
}

# step 0. load ref structure
mol new ${refFILE}


# step 1. load all trajectories
mol new ${refFILE}
foreach filename ${argv} {
	mol addfile ${filename} waitfor all
}

set frames [molinfo top get numframes]
puts "Total Frames $frames"

# step 2. remove degree of freedom of trans. and rot.
for {set seli 0} {$seli < ${K_num}} {incr seli} {
	set idx_s [expr $seli * ${Kn} * ${CG_resolution} +1]
	set idx_e [expr [expr $seli +1] * ${Kn} * ${CG_resolution}]

	set sel0 [atomselect 0 "serial ${idx_s} to ${idx_e}"]

	for {set i 0} {$i < ${frames}} {incr i} {
		set selall [atomselect top "all" frame $i]
		set sel1 [atomselect top "serial ${idx_s} to ${idx_e}" frame $i]
		set M [measure fit $sel1 $sel0]
		$selall move $M

		$selall delete
		$sel1 delete
	}

	# step 3. calculating RMSF
	#calc_rmsf ${idx_s} ${idx_e} ${output}
	set sel [atomselect top "serial ${idx_s} to ${idx_e}"]
	set rmsf [measure rmsf $sel first 1 last -1 step 1]
	
	
	for {set i 0} {${i} < [$sel num]} {incr i} {
		puts -nonewline $output [format "%4d" $i]
		puts $output [format "%12.6f" [lindex $rmsf ${i}]]
	}
	$sel delete
	$sel0 delete
}
