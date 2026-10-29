## Move the source contact matrix to the target population with convertPrem

## The default 40 iterations leaves ~10% fitting error for this matrix
its <- 1000

library(shellpipes)
sourceFiles()
loadEnvironments()

## Reference: source matrix symmetrized in its own population
## (POLYMOD is not exactly reciprocal, so we clean it first)
ref <- convertPrem(mm, orig_pop, iterations=its)


## Adjusted: convertPrem to the target population
adj <- convertPrem(mm, orig_pop, new_pop, iterations=its)

## Fitted preferences (on the symmetrized total-contact matrix)
phi <- mix2pref(symMat(sweep(mm, 1, orig_pop, `*`)), iterations=its)

dimnames(ref) <- dimnames(adj) <- dimnames(phi) <- dimnames(mm)

## Naive: reuse the (symmetrized) per-capita rates unchanged in the target population
naive <- ref

## Total contacts in the target population; reciprocity needs these symmetric
naiveTot <- sweep(naive, 1, new_pop, `*`)
adjTot <- sweep(adj, 1, new_pop, `*`)

## Checks
print(rbind(source=rowSums(mm), ref=rowSums(ref), adjusted=rowSums(adj)))
print(c(naiveAsym = max(abs(log(naiveTot/t(naiveTot))))
	, adjAsym = max(abs(log(adjTot/t(adjTot))))
))
print(round(adj/ref, 2))

## Summaries: mean contacts per person, and dominant eigenvalue
## (proportional to R0 for a homogeneous-susceptibility model)
domEig <- function(m) max(Re(eigen(m, only.values=TRUE)$values))
summ <- rbind(
	meanContacts = c(ref = sum(rowSums(ref)*orig_pop)/sum(orig_pop)
		, naive = sum(rowSums(naive)*new_pop)/sum(new_pop)
		, adj = sum(rowSums(adj)*new_pop)/sum(new_pop)
	)
	, eigen = c(ref = domEig(ref), naive = domEig(naive), adj = domEig(adj))
)
print(round(cbind(summ, adjVsRef = summ[, "adj"]/summ[, "ref"]), 3))

saveVars(mm, ref, naive, adj, phi, naiveTot, adjTot
	, orig_pop, new_pop, ageGroups, sourceLabel, targetLabel
)
