#!/bin/bash

for i in {1..20}
do
	echo 0 0 | gmx trjconv -f product.`printf "%02d" ${i}`.xtc -o product.`printf "%02d" ${i}`.wrap.xtc -s product.`printf "%02d" ${i}`.tpr -pbc whole
done
