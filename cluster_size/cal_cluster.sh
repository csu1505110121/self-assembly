#!/bin/bash

vmd -dispdev text -e cluster_v1.tcl -f ../../model_construct/k8_20_conc.gro -args ../product.??.wrap.xtc 
