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

## South Africa only (2026-10-28)

`make rsa_heatmaps.Rout` -> `rsa_heatmaps.Rout.pdf`. Source: Prem et al. 2021
synthetic matrix for ZAF (16 five-year groups, 75+ open; downloaded from
github.com/kieshaprem/synthetic-contact-matrices) with the WPP 2019 2020
population Prem used. Target: 2035, projected by applying age-specific
2020 -> 2035 growth ratios from WPP 2024 (2020 estimate, 2035 median
projection; data files fetched from github.com/PPgp/wpp2024 rather than
installing the package) to Prem's 2020 population. Same `adjust.R` and `heatmaps.R` as the UK example.

The only South African survey on socialcontactdata.org (CODA, Dodd et al.,
2011) surveyed only adults in Western Cape communities and recorded contact
ages in 5 coarse bins, so we did not use it.

Results (15-year projection):

* Population shares rise 15-48% for ages 40-54 and 70+, and fall 8-21% for
  under-10s and 20-39 (30-34 falls most, reflecting smaller cohorts born
  around 2000).
* Per-capita contact rates change from -24% to +54% by cell; the change is
  mostly by contact age (more contacts with people 40-54 and 70+, fewer with
  young children and people 30-34). Contacts with people 45+ rise from 18% to
  24% of all contacts.
* Mean contacts per person: -1.0%; dominant eigenvalue (proportional to R0):
  -0.9%. So overall transmission potential barely moves, but who contacts whom
  shifts noticeably.
* Naive reuse of the 2020 per-capita matrix in 2035 breaks reciprocity by up to
  ~1.9x (older participants' contacts with younger people overstated).
* With WPP 2017 projections instead (earlier version), results were similar in
  scale (-19% to +63% by cell; eigenvalue -1.4%), but WPP 2024 shows a
  distinct dip at 30-34.
* No `phi` shrinking was needed (no `pref2mix` warning).

Also changed: `naive` is now the symmetrized source matrix reused in the target
population, so panel C shows only the effect of the population change (before,
it also included non-reciprocity in the source data). Prem's matrix is not
reciprocal in its own population: symmetrizing raises 75+ per-capita contacts
from 6.5 to 8.1/day.

## Five-group two-panel figure (2026-10-28)

`make rsa5_pair.Rout` -> `rsa5_pair.Rout.pdf`. `coarse.R` aggregates the
Prem matrix and populations to 0-4, 5-19, 20-39, 40-59, 60+ (summing total
contacts, then dividing by group population); the standard `adjust.R` then
runs on the coarse matrix. `pair.R` shows (A) the 2020 per-capita matrix and
(B) percent change by 2035, with values printed in cells. Continuous palette
comes from `makestuff/okabe.R` defaults (viridis); panel B uses RdBu.

* Changes are mostly by contact age: -10 to -16% for contacts with 0-4 and
  20-39, ~0 to -6% with 5-19, +19 to +27% with 40-59 and 60+.
* Aggregating first and then adjusting gives nearly the same result as
  adjusting at 5-year resolution and then aggregating (within ~0.02).
* The changes are close to simply rescaling each column by the change in that
  group's population share; `convertPrem`'s extra contribution (keeping
  per-capita activity fixed) is a small correction here. The large contrast is
  with naive reuse (reciprocity error up to ~1.9x at 5-year resolution).
