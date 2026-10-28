
# NOTE: Contact matrices in this code should follow the convention that
# The row gives the individual and the column gives the contact
# This follows the convention used in the supplementary files in Prem et al.

library(readxl)

read_excel_allsheets <- function(filename, tibble = FALSE) {
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

source('./contact/mixpref.R') # Read in functions for manipulating matrices
source('./contact/unPop.R') # Read in UN estimates for 2017 for initial scaling

popdata = read_excel_allsheets("provagepop2020.xlsx")
prem = read_excel_allsheets("Contact_Prem_SA_nat_80.xlsx")

G<-17  #number of age groups 

natpop <- rowSums(as.matrix(popdata$pop5[,2:ncol(popdata$pop5)])) # National popuatlion

v = FALSE

prem_work <- as.matrix(prem$contact_work_5_80[,2:(G+1)])
print(convertPrem(prem_work, sa, natpop, verbose=v, eps=0))

prem_school <- as.matrix(prem$contact_school_5_80[,2:(G+1)])
print(convertPrem(prem_school, sa, natpop, verbose=v, eps=0))

