# Self-Assembly

- wrap/wrap\_trj.sh: trajectory wrapping using gromacs;

- cluster\_size: calculate the `number of cluster`, `maximum size of cluster`, and `L/D ratio`;
- rdf: rdf analysis;
- sasa: solvent accessible surface area analsysis;
- order\_param: order parameter analysis

```bash
## cal_order.sh
vmd -dispdev text -e order_v1.tcl -f ../../../model_construct/K4_0.15M_20_conc.gro -args ../product.??.wrap.xtc
```

- diffusion constant:
```
# utilizing gmx related commands
## combine multiple trajectories into one
gmx trjcat -cat -f [traj list] -o [name of combined traj] -settime -dt xxx
## calculate the MSD and estimate the $D$
gmx msd -f [path/to/combined traj] -s [path/to/topology] -o msdout.xvg -mol diff_mol.xvg
```

- num\_density/num\_density.tcl: calculate the num density of NA, CL, WATER
```bash
useage:
vmd -dispdev text -e num_density.tcl -f gro -args ../product.TOT.wrap.xtc
```

- dielectric constant
```bash
# create index.ndx file
gmx make_ndx -f tprfile/grofile -o index.ndx
# calculate the dielectric constant
gmx dipoles -f trjfiles -s tpr file -n index.ndx
```
