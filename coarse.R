## Aggregate a per-capita contact matrix and populations to coarser age groups

library(shellpipes)
loadEnvironments()

coarseLimits <- c(0, 5, 20, 40, 60)
coarseGroups <- c("0-4", "5-19", "20-39", "40-59", "60+")

lower <- as.numeric(sub("[-+].*", "", ageGroups))
g <- findInterval(lower, coarseLimits)
stopifnot(all(lower[match(seq_along(coarseLimits), g)] == coarseLimits))

## Per-capita rates -> total contacts, sum blocks, back to per-capita
aggPop <- function(pop) setNames(as.vector(tapply(pop, g, sum)), coarseGroups)
aggMat <- function(m, pop){
	tot <- rowsum(sweep(m, 1, pop, `*`), g)
	tot <- t(rowsum(t(tot), g))
	m <- sweep(tot, 1, aggPop(pop), `/`)
	dimnames(m) <- list(coarseGroups, coarseGroups)
	m
}

mm <- aggMat(mm, orig_pop)
orig_pop <- aggPop(orig_pop)
new_pop <- aggPop(new_pop)
ageGroups <- coarseGroups

print(round(mm, 2))
print(cbind(orig_pop, new_pop))

saveVars(mm, orig_pop, new_pop, ageGroups, sourceLabel, targetLabel)
