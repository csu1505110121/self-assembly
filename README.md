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
