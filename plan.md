# Plan: simple heatmap demonstration

Goal: a small figure (for a grant application) showing that `convertPrem`
moves a contact matrix to a new population while keeping per-capita activity
and mixing preferences, whereas naive reuse of the matrix does not.

## Data (public only)

* **Contact matrix**: `socialmixr` with the POLYMOD survey (built-in
  `polymod` data), e.g. `contact_matrix(polymod, countries = "United Kingdom",
  age.limits = seq(0, 70, 10), symmetric = FALSE)`. This gives per-capita rates
  (row = participant, column = contact) plus the survey population, matching
  the Prem convention used by `convertPrem`.
  (Alternative: Prem et al. 2017/2021 matrices, which are public, if we want a
  non-European example.)
* **Populations**: `socialmixr::wpp_age()` (UN World Population Prospects) to
  get age structure for the source country and one or two contrasting
  targets — e.g. UK (old) vs. a young population such as Niger or South
  Africa. Aggregate to the same age groups (~8 ten-year bands keep heatmaps
  readable).

## Steps

1. Fix `symMat` (`is.matrix`) so the code runs on current R.
2. `prep.R`: build the source contact matrix and source/target population
   vectors; save as `.rds`.
3. `adjust.R`: run `convertPrem(mm, orig_pop, new_pop)`; also compute the naive
   version (same per-capita matrix applied to new population). Check: row sums
   of per-capita matrix unchanged; total-contact matrix symmetric; `L == 1`.
4. `heatmaps.R` (ggplot2 `geom_tile`, shared colour scale, log scale if needed):
   * Panel A: original per-capita matrix (source population).
   * Panel B: naive matrix in target population, shown as total contacts —
     visibly non-symmetric (reciprocity violated).
   * Panel C: `convertPrem`-adjusted matrix in target population.
   * Optional Panel D: fitted preference matrix `phi`, to show "what is
     preserved", or ratio C/A.
   * Small bar inset or side panel of the two population pyramids.
5. Wire into the Makefile (pipeR style) so `make heatmaps.pdf` rebuilds.

## Checks / caveats to keep in mind

* Sensitivity of the result to `delta`/`alpha` (preference is not
  identifiable); maybe show one alternative in a supplement, not the main
  figure.
* Increase `iterations` or add a convergence check in `mix2pref`.
* POLYMOD has an open top age group; use the same top band for populations.

## Open questions

* Which source/target pair is most compelling for the grant?
* Show per-capita or total contacts in the main panels? (Total contacts make
  the reciprocity point; per-capita is what modellers usually see.)

## Status (2026-10-27)

Pipeline built: `make heatmaps.Rout` runs `prep.R` -> `adjust.R` ->
`heatmaps.R` and produces `heatmaps.Rout.pdf`. Page 1 is the 2x2 figure (A:
UK per capita, symmetrized; B: adjusted to South Africa 2020; C: reciprocity
error of naive reuse; D: log2 B/A). Page 2 is the fitted `phi`.

Findings so far:

* 40 iterations of `mix2pref` leave ~12% error for POLYMOD UK; 1000 iterations
  gets ~1e-6 and runs quickly, so `adjust.R` uses 1000.
* UK -> Niger (very young) is too extreme: `phi %*% p` exceeds 1 for children,
  `pref2mix` shrinks `phi` (factor ~1.2), and adult-child contacts collapse
  (to ~15% of UK rates), which is implausible. Results also depend strongly on
  `alpha`. UK -> South Africa, India or Italy all behave sensibly and are
  insensitive to `delta`/`alpha`, so the demo uses South Africa.
* Symmetrizing POLYMOD itself changes per-capita activity noticeably (70+
  falls from 7.3 to 5.7 contacts/day); panel A shows the symmetrized version
  so that D isolates the population effect.
