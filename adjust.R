## Move the source contact matrix to the target population with convertPrem

## The default 40 iterations leaves ~10% fitting error for this matrix
its <- 1000

library(shellpipes)
sourceFiles()
loadEnvironments()

## Reference: source matrix symmetrized in its own population
## (POLYMOD is not exactly reciprocal, so we clean it first)
ref <- convertPrem(mm, orig_pop, iterations=its)

## Naive: reuse per-capita rates unchanged in the target population
naive <- mm

## Adjusted: convertPrem to the target population
adj <- convertPrem(mm, orig_pop, new_pop, iterations=its)

## Fitted preferences (on the symmetrized total-contact matrix)
phi <- mix2pref(symMat(sweep(mm, 1, orig_pop, `*`)), iterations=its)

dimnames(ref) <- dimnames(adj) <- dimnames(phi) <- dimnames(mm)

## Total contacts in the target population; reciprocity needs these symmetric
naiveTot <- sweep(naive, 1, new_pop, `*`)
adjTot <- sweep(adj, 1, new_pop, `*`)

## Checks
print(rbind(source=rowSums(mm), ref=rowSums(ref), adjusted=rowSums(adj)))
print(c(naiveAsym = max(abs(log(naiveTot/t(naiveTot))))
	, adjAsym = max(abs(log(adjTot/t(adjTot))))
))
print(round(adj/ref, 2))

saveVars(mm, ref, naive, adj, phi, naiveTot, adjTot
	, orig_pop, new_pop, ageGroups, sourceCountry, targetCountry, targetYear
)
