# AMBER MD scripts

This directory contains a staged AMBER22 workflow for preparing, equilibrating, and running explicit-solvent molecular-dynamics systems. The numbered directories describe the intended order:

```text
0-parm -> 1-prep -> 2-min -> 3-heat -> 4-equil -> 5-prod
```

Most scripts **generate** AMBER input files and launcher scripts. They do not necessarily execute the generated input. Run them from the system directory containing the PDB, ligand parameter files, and generated topology files unless a script says otherwise.

## Input assumptions

The input PDB files are assumed to have already been processed before entering this workflow. In particular, they should have:

- hydrogen atoms and missing residues modeled;
- solvent fragments removed;
- appropriate protonation states assigned for titratable residues;
- disulfide bonds modeled; and
- ligands or other non-canonical small molecules identified for parameterization, if present.

Not every system requires ligand parameterization. Systems without a ligand or other non-canonical molecule are apo systems and can skip `0-parm`.

## Directory inventory

### `0-parm`: ligand and custom-residue parameterization

This stage uses Antechamber-family tools to process ligand information or another non-canonical small molecule. It supports both non-covalently bound small-molecule inhibitors and capped modified amino-acid residues used to model covalently bound inhibitors. It is only required when the system contains a ligand or modified residue that AMBER does not already parameterize.

- `run_antechamber.sh`: converts a ligand to Antechamber `.ac`, Prepgen `.prepin`, and Parmchk2 `.frcmod` files. Arguments are ligand basename, residue name, atom-type/force-field name, and input format.
- `run_parm_dimer.sh`: creates ligand parameters and a solvated dimer TLeap input. It uses fixed dimer ion counts and currently mixes parameter generation with system preparation.
- `run_parm_monomer.sh`: monomer counterpart of `run_parm_dimer.sh`; uses monomer ion counts. Its generated Antechamber helper is currently not executed.
- `run_parmchk2_gaff.sh`: fixed-name Parmchk2 wrapper using GAFF defaults.
- `run_parmchk2_parm10.sh`: fixed-name Parmchk2 wrapper using `parm10.dat`.
- `run_parmchk2_parm19.sh`: fixed-name Parmchk2 wrapper using `parm19.dat`.
- `run_prepgen.sh`: converts a fixed `.ac` file into a `.prepin` file using a fixed Prepgen model.
- `run_tleap_parm.sh`: loads protein, GAFF, and custom parameter files, checks a PDB, and writes an OFF library plus unsolvated topology and coordinates.

For covalent parameterization, this directory is missing a generator for the residue-specific `.mc` file used by `prepgen`. That file should be generated from the capped modified-residue model and kept with the other parameterization inputs. The future parameterization workflow should make this step explicit rather than relying on a manually supplied `.mc` file.

### `1-prep`: system preparation

These scripts use files created in `0-parm`, when applicable, and generate TLeap input files. They do not run TLeap. The TLeap input defines the topology and coordinate files required to run AMBER, including the force fields, water model, solvent box, ion types, ion counts for the target experimental concentration, and additional counterions needed to neutralize the system.

The generated TLeap input depends on the number of protein chains, whether a ligand is absent, non-covalently bound, or represented as a covalently modified residue, and how many ions are needed for the desired salt concentration and charge neutralization. A useful future extension is to generate alternative topology sets for explicitly selected mutated residues.

Residue numbering is a critical interface between this stage and the later simulation stages. Current defaults use protein residues `1-306` for a monomer and `1-612` for a dimer; ligand or modified-residue ranges follow those protein residues. These masks are used to generate restraint masks in `2-min`, `3-heat`, `4-equil`, and `5-prod`, so they must be checked against the prepared PDB rather than assumed blindly.

- `make_prep_apo.sh`: prepares an apo dimer with ff19SB, OPC, a 10-A octahedral box, and fixed dimer ion counts.
- `make_prep_monomer.sh`: prepares a ligand-bound monomer using GAFF ligand files, ff19SB, OPC, and monomer ion counts.
- `make_prep_dimer.sh`: standard ligand-bound dimer counterpart.
- `make_prep_customaa_monomer.sh`: custom-AA monomer preparation using `.prepin` and multiple `.frcmod` files.
- `make_prep_customaa_dimer.sh`: custom-AA dimer counterpart.

Typical generated outputs are `tleap_*.in`, `*_solvated.prmtop`, `*_solvated.inpcrd`, `*_solvated.pdb`, and `*_solvated.lib`.

The topology, coordinate, and restart files produced here become inputs to the AMBER runs in `2-min`, `3-heat`, `4-equil`, and `5-prod`. Those stages produce trajectories, restart files, and log files that are subsequently consumed by cpptraj input scripts for alignment, representative structures, and other preparation-stage analyses.

### `2-min`: minimization

Each generator writes AMBER minimization inputs and a `run_min.sh` launcher using `pmemd.cuda`.

- `make_min_monomer.sh`: five stages: heavy-atom restraint, protein restraint, backbone restraint, ligand restraint, and unrestrained minimization.
- `make_min_dimer.sh`: five-stage dimer protocol.
- `make_min_dimer_asym.sh`: five-stage asymmetric-dimer protocol.
- `make_min_apo_monomer.sh`: four effective stages without a ligand-restraint stage.
- `make_min_apo_dimer.sh`: apo dimer counterpart.

The protein and ligand residue ranges are hard-coded in these scripts. The generated stages chain `min1` through `min5` using restart files.

### `3-heat`: heating

- `make_heat_monomer.sh`: generates 250 ps restrained NVT heating followed by 250 ps unrestrained heating.
- `make_heat_dimer.sh`: dimer variant with dimer restraint masks.
- `make_heat_dimer_asym.sh`: asymmetric-dimer variant.

Each script generates `rheat.mdin`, `heat.mdin`, and `run_heat.sh`. The runner starts from the final minimization restart.

### `4-equil`: equilibration and processing

- `make_equil_monomer.sh`: generates restrained and unrestrained 250 ps NPT equilibration, a runner, and a cpptraj processing input.
- `make_equil_dimer.sh`: symmetric dimer variant.
- `make_equil_dimer_asym.sh`: asymmetric dimer variant.
- `make_process_equil.sh`: generates a cpptraj input that autoimages, aligns, and writes an aligned trajectory and representative PDB.

The normal restart chain is `heat.rst -> requil.rst -> equil.rst`.

### `5-prod`: production

- `make_prod.sh`: generates a 250 ns NPT production input and a GPU SLURM launcher. The generated launcher currently has only replica 1 enabled; later replica commands remain commented out.

Scheduler account, partition, GPU, Conda, and wall-time settings are cluster-specific and should eventually be configuration rather than scientific workflow logic.

### `io`: file organization

- `cleanup.sh`: creates `parm`, `prep`, and `prod` directories and moves files using filename globs. It also copies topology and equilibration files for replicas.
- `undo_cleanup.sh`: attempts to restore the flat layout produced before cleanup.

These scripts are destructive and not reliably idempotent. Do not use them on an irreplaceable run directory without a backup.

### `run_scripts`: orchestration

- `run_all.sh`: intended full pipeline driver; generates stages, runs TLeap, and sources minimization/heating/equilibration runners.
- `run_all_monomer.sh`: monomer pipeline variant.
- `run_all_dimer.sh`: dimer pipeline variant.
- `run_all_dimer_asym.sh`: asymmetric dimer pipeline variant.
- `run_all_nirm.sh`: site-specific custom-AA workflow for three MPro systems.
- `run_min.sh`: standalone legacy minimization runner.

These scripts currently contain obsolete absolute paths, ambiguous positional arguments, and inconsistent assumptions about generated filenames. Treat them as legacy wrappers until they are replaced by a profile-driven driver.

### Root-level workflows

- `Run_gamd.sh`: PBS GaMD workflow. It stages `${case}*` into `$TMPDIR`, runs minimization and heating, executes a long GaMD simulation, then copies outputs back.
- `make-mdin-peptide-full-main.sh`: monolithic generator for monomer, dimer, and asymmetric-dimer `min`, `heat`, `equil`, and `prod` directories. It duplicates the numbered stage generators.
- `solvate-pdb.sh`: incomplete prototype for volume-aware solvation and ion calculation. It currently generates TLeap files but does not implement the volume calculation or execute the generated inputs.

## Current variants

| Variant | Preparation | Protein mask | Ligand mask | Ligand minimization |
| --- | --- | --- | --- | --- |
| ligand monomer | `make_prep_monomer.sh` | `:1-306` | approximately `:307` or `:307-317` | yes |
| ligand dimer | `make_prep_dimer.sh` | `:1-612` | approximately `:613-614` or `:613-633` | yes |
| ligand asymmetric dimer | `make_prep_dimer.sh` | `:1-612` | approximately `:613` or `:613-623` | yes |
| apo monomer | `make_prep_apo.sh` or custom preparation | system-dependent | none | no |
| apo dimer | `make_prep_apo.sh` | system-dependent | none | no |
| custom-AA monomer/dimer | `make_prep_customaa_*.sh` | system-dependent | custom residue files | depends on generated mask |

The masks above are historical defaults, not guarantees. They must be checked against the actual PDB residue numbering before a run.

## Main reuse problems

1. Monomer, dimer, asymmetric-dimer, apo, and custom-AA differences are encoded by duplicated filenames and hard-coded residue masks.
2. The same AMBER namelists and `pmemd.cuda` command chains are repeated across multiple generators and the monolithic generator.
3. Generation and execution are mixed, and scripts depend on the caller's current directory.
4. Force fields, water models, ion counts, durations, scheduler settings, and environment activation are not consistently configurable.
5. Several orchestration scripts refer to the historical `make_md_scripts` path or source generated scripts rather than executing them.
6. `cleanup.sh` uses destructive filename globs; `solvate-pdb.sh` is incomplete; production replicas are partly disabled.
7. Most scripts lack argument validation and fail-fast behavior such as `set -euo pipefail`.

## Reorganization plan

### Phase 1: document and freeze behavior

1. Treat the current generated filenames, residue masks, ion counts, force fields, water models, temperatures, durations, and restart transitions as a compatibility contract.
2. Record one representative generated output for each supported variant before changing implementation.
3. Mark site-specific and incomplete workflows as legacy or prototype.

### Phase 2: consolidate generation

1. Add a shared shell library for argument validation, path resolution, Amber executable lookup, logging, and safe directory creation.
2. Replace duplicated stage scripts with one generator each for preparation, minimization, heating, equilibration, and production.
3. Store variant differences in explicit profiles: masks, ion counts, ligand-loading mode, force fields, water model, box padding, stage lengths, replicas, and scheduler profile.
4. Add explicit `--dry-run`, `--force`, and generate-only/run-only behavior.

### Phase 3: separate orchestration and execution

1. Create one pipeline driver for `prep -> tleap -> min -> heat -> equil -> prod`.
2. Replace `run_all_*` scripts with thin profile-driven wrappers.
3. Keep scientific AMBER inputs separate from PBS/SLURM and environment configuration.
4. Keep GaMD as a separate workflow using the same path and validation helpers.

### Phase 4: safer file handling

1. Replace glob-based cleanup with a run-directory layout and an artifact manifest.
2. Make organization operations idempotent and refuse ambiguous overwrites.
3. Migrate `make-mdin-peptide-full-main.sh` to the shared generators, then deprecate it after generated-output comparison.

### Phase 5: verification

1. Run `bash -n` and ShellCheck on maintained scripts.
2. Test generation with fake `tleap`, `pmemd.cuda`, `cpptraj`, `antechamber`, `parmchk2`, and `sbatch` commands.
3. Compare masks, ion counts, generated filenames, restart chaining, and scheduler directives against compatibility fixtures.
4. Perform cluster smoke runs for monomer, symmetric dimer, asymmetric dimer, and custom-AA systems before removing legacy wrappers.

## Safety notes

- Verify residue numbering and restraint masks from the actual PDB before running.
- Do not change force fields, water models, salt counts, or ensemble settings during refactoring without an explicit protocol decision.
- Run destructive organization scripts only on a backed-up or disposable directory.
- The current worktree contains historical file moves and modifications outside this README; those changes are intentionally preserved.
