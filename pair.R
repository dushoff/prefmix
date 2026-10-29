## Two-panel figure: source matrix, and percent change to the target population

library(shellpipes)
library(ggplot2)
library(patchwork)
sourceFiles()
loadEnvironments()
startGraphics(width=9, height=4.5)

## Long format; row = participant (y), column = contact (x)
long <- function(m){
	data.frame(part = factor(rownames(m)[row(m)], levels=ageGroups)
		, cont = factor(colnames(m)[col(m)], levels=ageGroups)
		, value = as.vector(m)
	)
}

base <- function(d, title){
	(ggplot(d, aes(cont, part, fill=value))
		+ geom_tile(colour="white")
		+ coord_equal()
		+ labs(x="Age of contact", y="Age of participant", title=title)
		+ theme_minimal(base_size=11)
		+ theme(panel.grid=element_blank())
	)
}

dA <- long(ref)
dA$label <- sprintf("%.1f", dA$value)
## Continuous palette comes from the okabe.R default (viridis)
pA <- (base(dA, paste0("A. ", sourceLabel, "\ncontacts per person per day"))
	+ scale_fill_continuous(trans="log2", guide="none")
	+ geom_text(aes(label=label), size=3.5
		, colour=ifelse(dA$value > median(dA$value), "black", "white")
	)
)

dB <- long(log2(adj/ref))
pct <- round(100*(2^dB$value - 1))
dB$label <- paste0(ifelse(pct>0, "+", ""), pct, "%")
lim <- max(abs(dB$value))
pB <- (base(dB, paste0("B. Change by ", sub(" \\(.*", "", targetLabel)))
	+ scale_fill_distiller(palette="RdBu", limits=c(-lim, lim), guide="none")
	+ geom_text(aes(label=label), size=3.5)
)

print(pA + pB)
