#!/bin/bash

vmd -dispdev text -e dssp.tcl -f ../../model_construct/K4_0.15M_20_conc.gro -args ../product.??.wrap.xtc
