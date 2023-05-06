#!/bin/bash

vmd -e gyration.tcl -f ../../equilibrate/equilibration.gro -args ../product.??.wrap.xtc
