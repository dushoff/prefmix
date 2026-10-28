## Heatmaps illustrating convertPrem

library(shellpipes)
library(ggplot2)
library(patchwork)
loadEnvironments()
startGraphics(width=10, height=9)

## Long format; row = participant (y), column = contact (x)
long <- function(m){
	data.frame(part = factor(rownames(m)[row(m)], levels=ageGroups)
		, cont = factor(colnames(m)[col(m)], levels=ageGroups)
		, value = as.vector(m)
	)
}

base <- function(m, title){
	(ggplot(long(m), aes(cont, part, fill=value))
		+ geom_tile(colour="white")
		+ coord_equal()
		+ labs(x="Age of contact", y="Age of participant", title=title, fill=NULL)
		+ theme_minimal(base_size=11)
		+ theme(axis.text.x = element_text(angle=45, hjust=1), panel.grid=element_blank())
	)
}

rateLim <- range(c(ref, adj))
rateScale <- scale_fill_viridis_c(trans="log2", limits=rateLim
	, breaks=c(0.125, 0.5, 2, 8), labels=c("1/8", "1/2", "2", "8")
	, name="Contacts\nper day"
)

divScale <- function(m, name){
	lim <- max(abs(m))
	scale_fill_distiller(palette="RdBu", limits=c(-lim, lim), name=name)
}

pA <- base(ref, paste0("A. ", sourceCountry, " (POLYMOD), per capita")) + rateScale
pB <- base(adj, paste0("B. Adjusted to ", targetCountry, " ", targetYear, ", per capita")) + rateScale

asym <- log2(naiveTot/t(naiveTot))
pC <- (base(asym, paste0("C. Naive reuse in ", targetCountry, ": reciprocity error"))
	+ divScale(asym, "log2 ratio\n(i,j) vs (j,i)")
)

chg <- log2(adj/ref)
pD <- (base(chg, "D. Change in per-capita rates (B vs A)")
	+ divScale(chg, "log2 ratio")
)

print((pA + pB) / (pC + pD))

## Supplementary: fitted preference matrix
print(base(phi, "Fitted preference matrix (phi)")
	+ scale_fill_viridis_c(option="magma", name="phi")
)
