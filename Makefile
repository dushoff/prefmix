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
