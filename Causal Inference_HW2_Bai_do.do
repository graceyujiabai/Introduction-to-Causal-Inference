cd "C:\Users\bai2\OneDrive - The University of Chicago\Desktop\Homework_2
use webster
describe
//drop data
keep if (treadss1 != 999)

//check sample size for two racial groups
table srace

//question 1
//kindergarten classroom assignment
table cltypek
//first grade classroom assignment
table cltype1

//IV variable Z
generate Z=0
replace Z=1 if cltypek==1
//treatment variable D
generate D=0
replace D=1 if cltype1==1
//Y outcome
generate Y = treadss1
//recode race variable
generate race=0
replace race=1 if srace==2
tab race
tab srace


//check correlation between instrumental variable and treatment
correlate Z D
//see how many individuals are in each category
tabulate Z D
//tabulate with race variable
table race Z D, contents(freq)


//question 3
//PF
reg treadss1 D if race==1
//ITT effect of Z on D
reg D Z if race==1
reg Y Z if race==1

//predict D_hat, xb
//stage 2
//regress treadss1 D_hat
//////////////////////////////////////////////////////////////////

//q4 only for AfAm
ivregress 2sls treadss1 (D=Z) if race==1, first


//q6 2SLS for group 0
tab srace
ivregress 2sls treadss1 (D=Z) if race==0, first


//q9
//endogeneity test
reg Y Z if (race==0 & D==1)
reg Y Z if (race==0 & D==0)

reg Y Z if (race==1 & D==1)
reg Y Z if (race==1 & D==0)


reg Y Z if D==0
reg Y Z if D==1