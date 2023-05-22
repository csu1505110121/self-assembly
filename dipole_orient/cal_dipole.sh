#!/bin/bash

vmd -e dipole_orient.tcl -f ../../model_construct/K40_0.75M_20_conc.gro -f ../../k40_0.75m.pqr -args ../product.TOT.xtc 
