cd "C:\Users\bai2\OneDrive - The University of Chicago\Desktop\Causal Inference\homework\Exercise_1r"
use GSS83_91_ex1
describe
keep if (wrkstat > 0) & (wrkstat < 8)
keep if (age >= 25) & (age < 65)
keep if (tvhours >= 0) & (tvhours < 98)
keep if (attend < 9)
keep if (educ>=0) & (educ <= 20)
generate RACE_D=0
replace RACE_D=1 if race==2
generate WD=inrange(wrkstat,3,7)
generate ATDDMY=inrange(attend,4,8)
generate AGE10=trunc((age-5)/10)
recode educ (0/11=1)(12=2)(13/15=3)(16=4)(17/20=5), generate(EDUC5)
generate AGE35_54=0
replace AGE35_54=inrange(AGE10,3,4)
gen INT=WD*AGE35_54
describe

//question 1
logit ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT


//question 2
//INTERPRETATION


//question 3
predict yhat1
generate propen=yhat1
tabulate propen
generate LGT_P=log(propen/(1-propen))
generate LGT = round(LGT_P, 0.1)
generate LGT10=trunc(LGT_P*10+0.5)
//or: predict lgt, xb
by ATDDMY, sort:sum LGT10
tabulate LGT ATDDMY //observations are all in the common area of support
twoway (histogram LGT10 if ATDDMY==1, color(pink%30)) ///
	   (histogram LGT10 if ATDDMY==0, ///
	   color(green%30)),legend(order(1 "frequent church" 2 "no church")) //keep all
	   
reg tvhours ATDDMY
reg tvhours ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT

//check answers with another method:
//psmatch2 ATDDMY ib2.AGE10* ib2.EDUC5* i.RACE_D* i.WD*, out(tvhours) common
//psgraph
//pstest ib2.AGE10* ib2.EDUC5* i.RACE_D* i.WD*

	   
//question 4
//generate STR=trunc((LGT+0.61)/0.23+1)//old way
//code strata in new way below
recode LGT10 (-5/-3=1)(-2/-1=2)(0=3)(1=4)(2=5)(3=6)(4/6=7)(7/9=8)(10/14=9), gen(STR)

//question 5
tabulate STR ATDDMY
//check if strata are in the ranges we want
tabulate STR LGT10


//question 6
//q6 (1) examine if there is signficance in each strata
//within stratum
by STR, sort : regress LGT_P ATDDMY
//q6 (2) estimate the average difference in the logit in the entire sample, controlling for strata, and its standard error
regress LGT_P ATDDMY i.STR

//question 7
logit ATDDMY i.EDUC5 i.STR
logit ATDDMY i.RACE_D i.STR
logit ATDDMY i.AGE10 i.STR
logit ATDDMY i.WD i.STR

//see if anything is significant
logit ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT i.STR

//question 8
//ATE
teffects psmatch (tvhours) (ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT) 
tebalance summarize
//ATT
//teffects psmatch (tvhours) (ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT), atet
//tebalance summarize


//IPTW problems
ssc install fre
//ssc install STRAT.exe

//create weights & q9
tabulate ATDDMY
generate WGT=ATDDMY*0.5295/propen+(1-ATDDMY)*0.4705/(1-propen)
generate WGT1=ATDDMY*WGT
generate WGT0=(1-ATDDMY)*WGT
summarize WGT WGT1 WGT0
//weighted means look similar to the observed

//q10
replace WGT1=WGT1*(0.5295/0.5286)
replace WGT0=WGT0*(0.4705/0.4715)
replace WGT=WGT1+WGT0
summarize WGT WGT1 WGT0

//q11
reg ATDDMY LGT_P [aw=WGT]


//q12 check independence
//describe//look at variables again
reg ATDDMY ib2.AGE10 [aw=WGT]
reg ATDDMY ib2.EDUC5 [aw=WGT]
reg ATDDMY i.RACE_D [aw=WGT]
reg ATDDMY i.WD [aw=WGT]


//q13 IPTW estimate of ATE
reg tvhours ATDDMY [aw=WGT], robust

//q14 ATE with STATA teffects method
teffects ipw (tvhours) (ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT)
tebalance summarize

//q15
//lm 1
regress tvhours ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT
//lm2
regress tvhours ATDDMY [aw=WGT]
//lm3
regress tvhours ATDDMY ib2.AGE10 ib2.EDUC5 i.RACE_D i.WD i.INT [aw=WGT], robust