## South Africa only: Prem et al. (2021) synthetic contact matrix,
## with population projected from 2020 to 2035

library(shellpipes)
suppressMessages(library(socialmixr))

baseYear <- 2020
projYear <- 2035
ageLimits <- seq(0, 75, 5)
ageGroups <- c(paste(head(ageLimits, -1), tail(ageLimits, -1)-1, sep="-"), "75+")

## Per-capita rates: row = individual, column = contact (16 groups, 75+ open)
e <- new.env()
load(matchFile("contact_all.rdata"), envir=e)
mm <- e$contact_all[["ZAF"]]
dimnames(mm) <- list(ageGroups, ageGroups)

## Population Prem used (UN WPP 2019, 2020, thousands), in 5-year groups to 100+
pp <- read.csv(matchFile("popage_total2020.csv"), check.names=FALSE)
za <- unlist(pp[pp[[1]]=="South Africa", grep("^age", names(pp))])
agg <- function(pop, lower) as.vector(tapply(pop, findInterval(lower, ageLimits), sum))
orig_pop <- setNames(agg(za, as.numeric(sub("age", "", names(za)))), ageGroups)

## Project with age-specific growth ratios from the WPP 2017 median projection
## (bundled with socialmixr), applied to Prem's 2020 population
wp <- suppressWarnings(wpp_age("South Africa", c(baseYear, projYear)))
wpAgg <- function(y){
	w <- wp[wp$year==y, ]
	agg(w$population, w$lower.age.limit)
}
growth <- wpAgg(projYear)/wpAgg(baseYear)
new_pop <- orig_pop*growth

print(round(mm, 2))
print(cbind(orig_pop, new_pop, growth=round(growth, 3)
	, shareRatio = round((new_pop/sum(new_pop))/(orig_pop/sum(orig_pop)), 3)
))

sourceLabel <- paste("South Africa", baseYear, "(Prem 2021)")
targetLabel <- paste("South Africa", projYear, "(projected)")

saveVars(mm, orig_pop, new_pop, ageGroups, sourceLabel, targetLabel)
