## This is prefmix

current: target
-include target.mk
Ignore = target.mk

## make ghrepo_public

vim_session:
	bash -ic "vmt"

## -include makestuff/perl.def

######################################################################

Sources += $(wildcard *.R *.md)

## claude.md

test.R:
mixpref.R:

## Demonstration (public data: POLYMOD UK, WPP populations)
autopipeR = defined

prep.Rout: prep.R
adjust.Rout: adjust.R mixpref.R prep.rda
heatmaps.Rout: heatmaps.R adjust.rda

## South Africa only: Prem et al. 2021 synthetic matrix (2020), projected to 2035
premurl = https://raw.githubusercontent.com/kieshaprem/synthetic-contact-matrices/master/generate_synthetic_matrices
Ignore += prem
prem/contact_all.rdata:
	mkdir -p prem && curl -sfL -o $@ $(premurl)/output/syntheticmatrices/contact_all.rdata
prem/popage_total2020.csv:
	mkdir -p prem && curl -sfL -o $@ $(premurl)/input/pop/popage_total2020.csv

## WPP 2024 data files (not installing the package)
wppurl = https://raw.githubusercontent.com/PPgp/wpp2024/main/data
Ignore += wpp2024
wpp2024/%.rda:
	mkdir -p wpp2024 && curl -sfL -o $@ $(wppurl)/$*.rda

rsa_prep.Rout: rsa_prep.R prem/contact_all.rdata prem/popage_total2020.csv wpp2024/popAge1dt.rda wpp2024/popprojAge1dt.rda
rsa_adjust.Rout: adjust.R mixpref.R rsa_prep.rda
	$(pipeR)
rsa_heatmaps.Rout: heatmaps.R rsa_adjust.rda
	$(pipeR)
## heatmaps.Rout.pdf: heatmaps.R

######################################################################

### Makestuff

Sources += Makefile

Ignore += makestuff
msrepo = https://github.com/dushoff

## ln -s ../makestuff . ## Do this first if you want a linked makestuff
Makefile: makestuff/00.stamp
makestuff/%.stamp: | makestuff
	- $(RM) makestuff/*.stamp
	cd makestuff && $(MAKE) pull
	touch $@
makestuff:
	git clone --depth 1 $(msrepo)/makestuff

-include makestuff/os.mk

-include makestuff/pipeR.mk

-include makestuff/git.mk
-include makestuff/visual.mk
