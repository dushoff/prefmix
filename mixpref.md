# What mixpref.R does

## Purpose

Contact matrices (e.g., Prem et al.) are estimated for one population age
structure. If we apply them to a different population (another country,
province, year, or scenario), the matrix is no longer consistent: the total
number of contacts from group i to group j should equal the total from j to i,
and per-capita activity should not change just because a group got bigger.

`mixpref.R` addresses this by separating a mixing matrix into
(a) **activity**: how many contacts each group makes in total, and
(b) **preference**: who each group prefers to mix with, beyond random mixing.
It then keeps the preferences, changes the activity, and rebuilds the matrix.

## Notation

* `rho` – symmetric *total*-contact matrix (rho[i,j] = total contacts between
  groups i and j, per unit time). Its row sums are the activity vector `T`.
* `T` – total activity of each group; `p = T/sum(T)` is each group's share of
  all activity.
* `phi` – symmetric preference matrix.
* Prem-style matrix `mm` – *per-capita* rates (row = individual, column =
  contact), so `mm * pop` (by row) is a total-contact matrix.

## The model (`pref2mix`)

Given `phi` and `T`:

    pp_i  = sum_j phi[i,j] p_j          # share of i's activity that is "preferential"
    L     = max(1, Lfac * max(pp))      # Lfac = 1.01
    if L > 1: phi <- phi/L; pp <- pp/L  # shrink preferences (with a warning)
    sig_i = 1 - pp_i                    # share left over for proportionate mixing
    D     = sum_i p_i sig_i
    rho[i,j] = (T_i T_j / sum(T)) * ( phi[i,j] + sig_i sig_j / D )

So each entry is the random-mixing ("proportionate") expectation
`T_i T_j / sum(T)` multiplied by a factor with two parts:

* `phi[i,j]` – the preferential part, and
* `sig_i sig_j / D` – a rank-one proportionate part that takes up whatever
  activity is not used by preferences. This is the classic
  "preferred + proportionate" structure (Nold; Jacquez et al.; Hethcote).

Properties (checked numerically):

* `rho` is symmetric by construction.
* Row sums are exactly `T`. If preferences are too strong for the given `p`
  (`max(phi %*% p) > 1/Lfac`), `phi` is shrunk uniformly by `L` and a warning
  is issued (`warn = FALSE` suppresses it; `mix2pref` does this internally).
  The original code instead inflated all activities by `L`; the new result is
  exactly the old one divided by `L`. `Lfac = 1.01` keeps every `sig_i > 0`
  (at least ~1% of the most-preferential group's activity is proportionate).
* When `L > 1`, `phi` and `c * phi` give the same matrix, so a fitted `phi` is
  only defined up to scale in that regime.
* `phi = 0` gives pure proportionate (random) mixing.

## Fitting preferences (`mix2pref`)

Given an observed `rho`, find `phi` such that `pref2mix(phi, T) ≈ rho`, with
`T = colSums(rho)`. Starts from `phi = alpha` off the diagonal and `delta` on it
(defaults 0.1 and 1), then iterates the multiplicative update

    phi <- phi * (rho + eps) / (pref2mix(phi, T) + eps)

40 times. This is like iterative proportional fitting; it preserves symmetry
and non-negativity. `eps` protects against 0/0 for empty cells.

Notes:

* In tests, the fit converges well (max error ~4e-5 after 40 iterations,
  ~1e-16 after 400). There is no convergence check.
* **The answer is not unique.** Different starting values (`delta`, `alpha`)
  give quite different `phi` that reproduce `rho` exactly. This is expected:
  the split between "preference" and "proportionate" mixing is not identifiable
  from a single matrix. The starting point acts as a (implicit) regularizer;
  the defaults favour a strongly diagonal, assortative `phi`.

## Adjusting to new activity (`popAdj`)

`popAdj(rho, Tnew)` = symmetrize `rho`, fit `phi` with `mix2pref`, then return
`pref2mix(phi, Tnew)`. The result is symmetric with row sums `Tnew`, and retains the fitted preferences.

Because `phi` is not unique, the adjusted matrix depends somewhat on
`delta`/`alpha` (in a test with a large shift in `T`, entries differed by up to
~20% between starting points, though margins agreed exactly).

## Prem wrapper (`convertPrem`)

`convertPrem(mm, orig_pop, new_pop)`:

1. Turn per-capita rates into totals: multiply each row by `orig_pop`.
2. Symmetrize (average with transpose) – enforces reciprocity.
3. Activity `ta` = row sums; new activity `ta_new = ta * new_pop / orig_pop`,
   i.e. **per-capita activity of each age group is held fixed**.
4. `popAdj` to the new activity.
5. Divide rows by `new_pop` to return per-capita rates.

## test.R

Applies `convertPrem` to the Prem et al. South Africa work and school matrices
(17 five-year age groups), converting from the UN 2017 population (`sa`, from
an `unPop.R` file not in this repo) to 2020 national population from
provincial data. These data files are not here and we will not use them.

## Issues spotted

* (Fixed) `symMat` failed in R >= 4.0 because `class(m)` is
  `c("matrix", "array")`; now uses `is.matrix(m)`.
* (Fixed) Row sums of `pref2mix` were silently inflated to `L*T` when `L > 1`;
  `phi` is now shrunk instead, with a warning. `Lmin` argument removed.
* `mix2pref` has no convergence check; `verbose` only prints matrices.
* Unused variables: `B` in `pref2mix`, `T` in `popAdj`.
* Dependence on `delta`/`alpha` is undocumented and affects results.
