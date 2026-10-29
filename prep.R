## Public data for the demonstration:
## POLYMOD (UK) contact matrix and UN WPP age distributions (via socialmixr)

library(shellpipes)
suppressMessages(library(socialmixr))

ageLimits <- seq(0, 70, 10)
sourceCountry <- "United Kingdom"
targetCountry <- "South Africa"
targetYear <- 2020
sourceLabel <- paste(sourceCountry, "(POLYMOD)")
targetLabel <- paste(targetCountry, targetYear)

## Per-capita contact rates: row = participant, column = contact (Prem convention)
## demography is the survey-year population socialmixr uses for this survey
cm <- suppressWarnings(contact_matrix(polymod
	, countries = sourceCountry, age_limits = ageLimits
	, symmetric = FALSE, return_demography = TRUE
))
mm <- unclass(cm$matrix)
ageGroups <- rownames(mm)
dimnames(mm) <- list(ageGroups, ageGroups)
orig_pop <- setNames(cm$demography$population, ageGroups)

## wpp_age is deprecated, but still the simplest public source bundled with socialmixr
tp <- suppressWarnings(wpp_age(targetCountry, targetYear))
grp <- findInterval(tp$lower.age.limit, ageLimits)
new_pop <- setNames(as.vector(tapply(tp$population, grp, sum)), ageGroups)

print(round(mm, 2))
print(cbind(orig_pop, new_pop))

saveVars(mm, orig_pop, new_pop, ageGroups, sourceLabel, targetLabel)
