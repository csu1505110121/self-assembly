#!/bin/tclsh

if {1} {
	set output1 [open "rdf-na.dat" "w"]
	set output2 [open "rdf-cl.dat" "w"]
	set output3 [open "rdf-pp.dat" "w"]
	set num_frames_total 0
}

mol new ../../equilibrate/equilibration.gro
foreach filename ${argv} {
	mol addfile ${filename} waitfor all
}

set selP [atomselect top "resname LYS"]
set selNA [atomselect top "name NA"]
set selCL [atomselect top "name CL"]

set rdf_na [measure gofr $selP $selNA delta 0.1 rmax 70 usepbc True first 0 last -1 step 1]
set rdf_cl [measure gofr $selP $selCL delta 0.1 rmax 70 usepbc True first 0 last -1 step 1]
set rdf_pp [measure gofr $selP $selP delta 0.1 rmax 70 usepbc True first 0 last -1 step 1]

set r_rdf_na [lindex ${rdf_na} 0]
set gofr_rdf_na [lindex ${rdf_na} 1]
set int_rdf_na [lindex ${rdf_na} 2]

set r_rdf_cl [lindex ${rdf_cl} 0]
set gofr_rdf_cl [lindex ${rdf_cl} 1]
set int_rdf_cl [lindex ${rdf_cl} 2]

set r_rdf_pp [lindex ${rdf_pp} 0]
set gofr_rdf_pp [lindex ${rdf_pp} 1]
set int_rdf_pp [lindex ${rdf_pp} 2]

#puts $rdf_cl

for {set i 0} {${i} < [llength $r_rdf_na]} {incr i} {
	puts -nonewline ${output1} [format "%10.4f " [lindex $r_rdf_na ${i}]]
	puts -nonewline ${output1} [format "%10.4f " [lindex $gofr_rdf_na ${i}]]
	puts ${output1} [format "%10.4f " [lindex ${int_rdf_na} ${i}]]
}

for {set i 0} {${i} < [llength $r_rdf_cl]} {incr i} {
	puts -nonewline ${output2} [format "%10.4f " [lindex $r_rdf_cl ${i}]]
	puts -nonewline ${output2} [format "%10.4f " [lindex $gofr_rdf_cl ${i}]]
	puts ${output2} [format "%10.4f " [lindex ${int_rdf_cl} ${i}]]
}

for {set i 0} {${i} < [llength $r_rdf_pp]} {incr i} {
	puts -nonewline ${output3} [format "%10.4f " [lindex $r_rdf_pp ${i}]]
	puts -nonewline ${output3} [format "%10.4f " [lindex $gofr_rdf_pp ${i}]]
	puts ${output3} [format "%10.4f " [lindex ${int_rdf_pp} ${i}]]
}

quit
