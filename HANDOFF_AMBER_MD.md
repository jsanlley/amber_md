# amber_md Remote Session Handoff

## Repository

- Repository root: `/Users/javingfun/github/amber_md`
- Git branch: `main`
- Remote: `origin` -> `https://github.com/jsanlley/amber_md.git`
- Amber is not installed on the current computer. AMBER-dependent execution must happen on the remote cluster/session.

## User goal

Organize and make reusable the AMBER workflows in `amber_md_scripts`. The user supplied important domain assumptions that are documented in `amber_md_scripts/README.md`.

Input PDB files are expected to already have hydrogens and missing residues modeled, solvent fragments removed, protonation states assigned, disulfides modeled, and ligands/non-canonical molecules identified.

## Work completed

- Added `amber_md_scripts/README.md` with:
  - per-directory and per-script descriptions;
  - PDB preprocessing assumptions;
  - optional versus required `0-parm` behavior;
  - covalent/non-covalent parameterization explanation;
  - missing covalent `.mc` generation step;
  - TLeap topology, solvation, ion, and mutation notes;
  - residue-mask and cpptraj stage relationships;
  - staged refactoring and verification plan.
- Added reusable `amber_md_scripts/3-heat/make_heat.sh`.
- Routed the three heating entry points through it:
  - `make_heat_monomer.sh`
  - `make_heat_dimer.sh`
  - `make_heat_dimer_asym.sh`
- Added reusable `amber_md_scripts/2-min/make_min.sh` covering:
  - `monomer`
  - `dimer`
  - `dimer_asym`
  - `apo_monomer`
  - `apo_dimer`
- Routed the five minimization entry points through it.
- Both reusable generators preserve current default residue ranges but accept an optional third argument, `number_residues`, so future TLeap-derived protein lengths can drive masks. For example:

```bash
amber_md_scripts/2-min/make_min.sh monomer system_name 350
amber_md_scripts/3-heat/make_heat.sh monomer system_name 350
```

The current defaults remain monomer `306` and dimer `612` protein residues.

## Validation status

- README `git diff --check` passed.
- Heating syntax and temporary-directory generation tests passed for the default masks.
- The first minimization custom-residue test reached the wrapper but failed with exit code `126` because the wrapper executable bit was not set in the temporary validation context. A subsequent permission-fix validation was cancelled when the user clarified the repository root. Re-run the checks from `/Users/javingfun/github/amber_md` on the remote session.
- No AMBER, TLeap, pmemd.cuda, cpptraj, or cluster smoke tests have been run locally.
- The shell history expansion issue in an earlier grep test was a test-command problem caused by `!@H=`, not an implementation failure.

## Important existing worktree state

The worktree already contained file moves/deletions under `amber_md_scripts` before the reusable-generator work. Preserve them; do not revert them:

- `amber_md_scripts/io/` and `amber_md_scripts/run_scripts/` are untracked replacement directories.
- `amber_md_scripts/make-mdin-peptide-full-main.sh` is untracked.
- Several old root-level orchestration and cleanup scripts show as deleted.
- Several old `5-prod` files show as deleted or modified.

Inspect `git status --short` before staging. The intended handoff commit should include the current worktree state only if the user confirms these existing moves belong in the checkpoint.

## Immediate next steps on the remote session

1. From the repository root, run:

```bash
cd /Users/javingfun/github/amber_md
chmod +x amber_md_scripts/2-min/make_min.sh \
  amber_md_scripts/2-min/make_min_*.sh \
  amber_md_scripts/3-heat/make_heat.sh \
  amber_md_scripts/3-heat/make_heat_*.sh
bash -n amber_md_scripts/2-min/make_min.sh amber_md_scripts/2-min/make_min_*.sh
bash -n amber_md_scripts/3-heat/make_heat.sh amber_md_scripts/3-heat/make_heat_*.sh
```

2. Test generation without Amber using a temporary directory. Avoid Bash history expansion in grep commands containing `!@H=` by using `set +H` or fixed-string patterns safely.
3. Remove the unreachable duplicated bodies remaining below the `exec` lines in the five minimization compatibility wrappers. They currently work as wrappers, but the old text should be deleted for maintainability.
4. Update `amber_md_scripts/README.md` with the optional `number_residues` argument and the new reusable generator entry points.
5. Continue the session plan by consolidating equilibration, then preparation, production, and finally the orchestration scripts.
6. Add fake-tool generation tests before attempting cluster execution.
7. Only after reviewing the complete status, commit and push the checkpoint.

## Suggested new-conversation prompt

> Continue the Amber workflow refactor in `/Users/javingfun/github/amber_md`. Read `HANDOFF_AMBER_MD.md` and `amber_md_scripts/README.md` first. Amber is unavailable locally, so validate shell generation only until the remote cluster session is active. Preserve the existing file moves/deletions under `amber_md_scripts`; do not revert them. First rerun the syntax and temporary generation checks for `2-min` and `3-heat`, remove unreachable duplicated wrapper bodies, document the optional `number_residues` argument, then continue consolidating the remaining duplicated stages. Do not change scientific defaults without calling them out.
