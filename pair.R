## Two-panel figure: source matrix, and percent change to the target population

library(shellpipes)
library(ggplot2)
library(patchwork)
sourceFiles()
loadEnvironments()
## Sized for one panel of a 7-inch-wide figure; don't rescale in LaTeX
startGraphics(width=3.6, height=2.4)

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
		+ theme_minimal(base_size=8)
		+ theme(panel.grid=element_blank()
			, plot.title=element_text(size=8)
			, axis.text.x=element_text(angle=45, hjust=1)
		)
	)
}

dA <- long(ref)
dA$label <- sprintf("%.1f", dA$value)
## Continuous palette comes from the okabe.R default (viridis)
pA <- (base(dA, paste0(sub(" \\(.*", "", sourceLabel), " contacts"))
	+ scale_fill_continuous(trans="log2", guide="none")
	+ geom_text(aes(label=label), size=2
		, colour=ifelse(dA$value > median(dA$value), "black", "white")
	)
)

dB <- long(log2(adj/ref))
pct <- round(100*(2^dB$value - 1))
dB$label <- paste0(ifelse(pct>0, "+", ""), pct, "%")
lim <- max(abs(dB$value))
## Target year only (target label is "<place> <year> (projected)")
pB <- (base(dB, paste0("Change by ", sub(".* ", "", sub(" \\(.*", "", targetLabel))))
	+ scale_fill_distiller(palette="RdBu", limits=c(-lim, lim), guide="none")
	+ geom_text(aes(label=label), size=2)
	## Rows are shared with the left panel
	+ theme(axis.title.y=element_blank(), axis.text.y=element_blank())
)

print(pA + pB)
