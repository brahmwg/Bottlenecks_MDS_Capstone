
####This script builds a dataset that roughly approximates the Bottlenecks to survival project data for Puntledge Qualicum Fall Chinook

library(plyr)
library(data.table)
library(ggplot2)
library("lubridate")



getwd()

set.seed=1




##2021



####This script builds a dataset that roughly approximates the Bottlenecks to survival project data for Puntledge Qualicum Fall Chinook

library(plyr)
library(data.table)
library(ggplot2)
library("lubridate")



getwd()

set.seed=1

#hatchtag is the number of hatchery tags applied
hatchtag<-5000
#hatchtagdate is the tagging date
hatchtagdate<- "2021-05-10"
#downantdet is the downstream antenna detection efficiency. This is likely quite low in some systems. Here approximated as 6% based on 10% mortality and Nanaimo detects in 2022
downantdet<-.06
#downmort is the mortality between release of hatchery fish and downstream detection. Here arbitrarily assigned as 0.1 which is half of hatchery release to estuary mortality for Pellett Cowichan study
downmort<-.10 
#rivdatest is the start date of river detections
rivdatest<- "2021-05-24"
#rivdatend is the end date of river detection
rivdatend<- "2021-06-19"
#estuarytag is the number of estuary tags applied, for 2022 at Nanaimo and Puntledge for Chinook it was about 2000
estuarytag<-2500
#estuarystockprop is the proportion that is the stock being modelled, based on 2021 genetics this could range from 5% (Punt summer, to 85% Punt Fall)
estuarystockprop<-.5
#estuaryhatchprop<-is the proportion that is the stock being modelled that are hatchery, this could range from 0% (Cowichan RST, to ~80% Punt summer)
estuaryhatchprop<-.5
#estuarytagdatest is the start of estuary tagging
estuarytagdatest<- "2021-06-01"
#estuarytagdatend is the end of estuary tagging
estuarytagdatend<- "2021-06-30"
#estuarydays is the number of tagging days
estuarydays<-8
#estmort is the mortality between detection of hatchery fish on downstream antenna and estuary tagging Here arbritrarily assigned as 0.1, which is half of hatchery release to estuary mortality for Pellett Cowichan study
estmort<-.10
#estuaryhatchrecaprate is the rate of recapture of hatchery fish during estuary tagging, based on a quick look it appears to have ranged from .002 to .004 in 2022 at Nanaimo and Punt
estuaryhatchrecaprate<-.003
#estuarywildmeanFL is the mean fork length which based on 2021 data does not change through June, possibly due to small fish passing through estuary, this value is for puntledge fall run Chinook
estuarywildmeanFL<-75
#estuarywildSDFL the value used here is for puntledge fall run Chinook
estuarywildSDFL<-11
#summort is the mortality between estuary tagging and mid september. Assigned here as 75% based on Cowichan work. Assumes same for wild and hatchery
summort<-.75
#microtagdatest is the start of micro tagging
microtagdatest<- "2021-09-16"
#microtagdatend is the end of micro tagging
microtagdatend<- "2022-04-15"
#microdays is the number of tagging days
microdays<-50
#microcatch is the catch, here based on puntledge in the second year of the study
microcatch<-600
#microcatchsd is the sd in daily catch, here arbitrary. If you increase this way the code is set up it ramps up the catch because catch cannot be 0. Code does not reflect the decline in CPUE that occurs through the season 
microcatchsd<-3
#microhatchprop is the hatchery proportion based on puntledge in second winter
microhatchprop<-0.08
#microdailymort is the daily mortality rate through winter
microdailymort<-0.006
#note that return rates below assume same situation as Cowichan where differential hatchery and wild mortality occurs after first winter and is twice the magnitude for hatchery
#hatchreturn is the absolute return rate on hatchery tags released at hatchery, based roughly on Cowichan Data 
hatchreturn <-0.005
#hatchreturnest is the return rate on hatchery tags applied in estuary, based roughly on Cowichan Data 
hatchreturnest <-hatchreturn/.8
#wildreturnest is the return rate on hatchery tags applied in estuary, based roughly on Cowichan Data 
wildreturnest <-hatchreturnest*2
#hatchreturnmicro is the return rate on hatchery tags applied in mirotrolling, based roughly on Cowichan but increased as tagging occurs later
hatchreturnmicro <-0.05
#wildreturnmicro is the return rate on hatchery tags applied in estuary, based roughly on Cowichan but increased as tagging occurs later
wildreturnmicro <-hatchreturnmicro *2
#maturity2 is the proportion returning as age 2
maturity2<-.1
#maturity3 is the proportion returning as age 3
maturity3<-.4
#maturity4 is the proportion returning as age 4
maturity4<-.4
#maturity5 is the proportion returning as age 5
maturity5<-.1



##Create Hatchery Tagging Data
tag<-seq(1,hatchtag,1)
date<-rep(hatchtagdate,hatchtag)
stage<-rep("facility",hatchtag)
origin<-rep("hatch",hatchtag)
fork_length_mm<-rep(NA,hatchtag)
action<-rep("tag",hatchtag)
data<-cbind(tag,date,stage,origin,fork_length_mm,action)
data<-as.data.frame(data)
data$tag<-(as.numeric(data$tag))
data$date<-as.Date(data$date, format = "%Y-%m-%d",origin="1970-01-01")


##Add downstream detects
#kill 10% of fish
#the dataframe "live" constitutes the tags left alive as we move through the stages. For this version mortality is random, not associated with length or origin
live<-subset(data,data$action=="tag")
live<-live[sample(nrow(live), (1-downmort)*nrow(live)), ]
#downdetect is the number of downstream detections
downdetect<-(hatchtag-hatchtag*downmort)*downantdet
#develop vector of days for downstream detections
rivdatest<- as.Date(rivdatest, format = "%Y-%m-%d",origin="1970-01-01")
rivdatest<-as.numeric(rivdatest)
rivdatend<- as.Date(rivdatend, format = "%Y-%m-%d",origin="1970-01-01")
rivdatend<-as.numeric(rivdatend)
days<-seq(rivdatest,rivdatend)
origin<-vector()
origin<-rep("hatch",downdetect)
tag<-sample(live$tag,downdetect,replace=F)
#detections occur randomly through outmigration period.. not really accurate as they would be right skewed
date<-sample(days,downdetect,replace=TRUE)
stage<-rep("downstream",downdetect)
fork_length_mm<-rep(NA,downdetect)
action<-rep("detect",downdetect)
down<-cbind(tag,date,stage,origin,fork_length_mm,action)
down<-as.data.frame(down)
down$date<-as.Date(as.numeric(down$date), format = "%Y-%m-%d",origin="1970-01-01")

#append downstream detections to dataset
data<-rbind(data,down)

##Add Estuary Tagging Data

#develop vector of estuary tagging days, catch is randomly assigned to days
estuarytagdatest<- as.Date(estuarytagdatest, format = "%Y-%m-%d",origin="1970-01-01")
estuarytagdatest<-as.numeric(estuarytagdatest)
estuarytagdatend<- as.Date(estuarytagdatend, format = "%Y-%m-%d",origin="1970-01-01")
estuarytagdatend<-as.numeric(estuarytagdatend)
days<-sample(estuarytagdatest:estuarytagdatend,estuarydays,replace=F)
estuarytag<-estuarytag*estuarystockprop
estuarytag<-estuarytag-estuaryhatchrecaprate*hatchtag


#build estuary wild dataframe
data$tag<-(as.numeric(data$tag))
lengthwildest<-round((1-estuaryhatchprop)*estuarytag)
origin<-rep("wild",lengthwildest)
tag<-seq(max(data$tag)+1,lengthwildest+max(data$tag),1)
date<-sample(days,lengthwildest,replace=TRUE)
stage<-rep("estuary",lengthwildest)
#length is normal around mean and independent of date as seen in the data
fork_length_mm<-round(rnorm(lengthwildest,estuarywildmeanFL,estuarywildSDFL))
action<-rep("tag",lengthwildest)
dataestuarywild<-cbind(tag,date,stage,origin,fork_length_mm,action)
dataestuarywild<-as.data.frame(dataestuarywild)
dataestuarywild$date<-as.Date(as.numeric(dataestuarywild$date), format = "%Y-%m-%d",origin="1970-01-01")
#append wild estuary tagging to data
data<-rbind(data,dataestuarywild)

#build estuary hatch dataframe

##model is for change in hatchery length with date for Punt Qual in spring 2021
mod1<-readRDS("estuaryhatchmod.rds")



data$tag<-(as.numeric(data$tag))
lengthhatchest<-round((estuaryhatchprop)*estuarytag)
origin<-rep("hatch",lengthhatchest)
tag<-seq(max(data$tag)+1,lengthhatchest+max(data$tag),1)
date<-sample(days,lengthhatchest,replace=TRUE)
stage<-rep("estuary",lengthhatchest)
fork_length_mm<-rep(NA,lengthhatchest)
action<-rep("tag",lengthhatchest)
dataestuaryhatch<-cbind(tag,date,stage,origin,fork_length_mm,action)
dataestuaryhatch<-as.data.frame(dataestuaryhatch)
#fork length is simulated by predicting from date model and adding random model residuals
newdata<-dataestuaryhatch
newdata$date<-as.numeric(newdata$date)-364
dataestuaryhatch$fork_length_mm<-predict(mod1,newdata)+sample(resid(mod1),nrow(dataestuaryhatch),replace=T)
dataestuaryhatch$date<-as.Date(as.numeric(dataestuaryhatch$date), format = "%Y-%m-%d",origin="1970-01-01")
#append estuary hatch data
data<-rbind(data,dataestuaryhatch)

#Add estuary hatchery recaps
#kill off another 10% of hatchery fish before recapture
live<-live[sample(nrow(live), (1-estmort)*nrow(live)), ]

estrecap<-(hatchtag*estuaryhatchrecaprate)
origin<-rep("hatch",estrecap)
tag<-sample(live$tag,estrecap,replace=F)
date<-sample(days,estrecap,replace=TRUE)
stage<-rep("estuary",estrecap)
fork_length_mm<-rep(NA,estrecap)
action<-rep("recap",estrecap)

estre<-cbind(tag,date,stage,origin,fork_length_mm,action)
estre<-as.data.frame(estre)
newdata<-estre
newdata$date<-as.numeric(newdata$date)-364
estre$fork_length_mm<-predict(mod1,newdata)+sample(resid(mod1),nrow(estre),replace=T)
estre$date<-as.Date(as.numeric(estre$date), format = "%Y-%m-%d",origin="1970-01-01")
estre

data<-rbind(data,estre)

##Now update live
#first add estuary tags
live<-rbind(live,dataestuaryhatch,dataestuarywild)
#now kill off 75% prior to september
live<-live[sample(nrow(live), (1-summort)*nrow(live)), ]

##Now microtrolling Data

#develop vector of days
microtagdatest<-as.Date(microtagdatest, format = "%Y-%m-%d",origin="1970-01-01")
microtagdatest<-as.numeric(microtagdatest)
microtagdatend<- as.Date(microtagdatend, format = "%Y-%m-%d",origin="1970-01-01")
microtagdatend<-as.numeric(microtagdatend)
days<-sample(microtagdatest:microtagdatend,microdays,replace = F)
days<-sort(days)
#this model is based on punt qual fall Chinook FL by date
mod2<-readRDS("micromod.rds")



for(n in 1:length(days)){
  #create a daily catch
  perday<-round(rnorm(1,microcatch/length(days),microcatchsd))  
  hatch<-round(perday*microhatchprop)
  wild<-round(perday-hatch)
  
  #build daily micro wild dataframe
  data$tag<-(as.numeric(data$tag))
  if(wild>0){
    origin<-rep("wild",wild)
    tag<-seq(max(data$tag)+1,wild+max(data$tag),1)
    date<-rep(days[n],wild)
    stage<-rep("micro",wild)
    fork_length_mm<-fork_length_mm<-rep(NA,wild)
    action<-rep("tag",wild)
    microwild<-cbind(tag,date,stage,origin,fork_length_mm,action)
    microwild<-as.data.frame(microwild)}
  
  #build dail micro hatch dataframe
  if(hatch>0){
    microwild$tag<-as.numeric(microwild$tag)
    origin<-rep("hatch",hatch)
    tag<-seq(max(microwild$tag)+1,hatch+max(microwild$tag),1)
    date<-rep(days[n],hatch)
    stage<-rep("micro",hatch)
    fork_length_mm<-fork_length_mm<-rep(NA,hatch)
    action<-rep("tag",hatch)
    microhatch<-cbind(tag,date,stage,origin,fork_length_mm,action)
    microhatch<-as.data.frame(microhatch)
    dailydata<-rbind(microwild,microhatch)}
  
  
  newdata<-dailydata
  newdata$date<-as.numeric(newdata$date)-364
  dailydata$fork_length_mm<-predict(mod2,newdata)+sample(resid(mod1),nrow(dailydata),replace=T)
  #add daily data 
  dailydata$date<-as.Date(as.numeric(dailydata$date), format = "%Y-%m-%d",origin="1970-01-01")
  
  
  data<-rbind(data,dailydata)
  #iteratively kill off fish since last day based on daily mort rate
  if(n>1){
    interval<-days[n]-days[n-1]
    dailysurvival<-(1-microdailymort)
    deaths<-round(nrow(live)-nrow(live)*dailysurvival^interval)
    live<-live[sample(nrow(live), nrow(live)-deaths), ]}
  #add new fish to live
  live<-rbind(live,dailydata)
  
}


##build returns, these are assigned based on rough return age proportions and the remaining live fish. 
hatchreturn <-hatchreturn*nrow(subset(data,data$stage=="facility"))
hatchreturnest <-round(hatchreturnest*nrow(subset(data,data$stage=="estuary"&data$origin=="hatch"&data$action=="tag")))
wildreturnest <-round(wildreturnest*nrow(subset(data,data$stage=="estuary"&data$origin=="wild"&data$action=="tag")))
hatchreturnmicro <-round(hatchreturnmicro*nrow(subset(data,data$stage=="micro"&data$origin=="hatch"&data$action=="tag")))
wildreturnmicro <-round(wildreturnmicro*nrow(subset(data,data$stage=="micro"&data$origin=="wild"&data$action=="tag")))



livehatch<-subset(live,live$stage=="facility")
liveesthatch<-subset(live,live$stage=="estuary"&live$origin=="hatch"&live$action=="tag")
liveestwild<-subset(live,live$stage=="estuary"&live$origin=="wild"&live$action=="tag")
livemicrohatch<-subset(live,live$stage=="micro"&live$origin=="hatch"&live$action=="tag")
livemicrowild<-subset(live,live$stage=="micro"&live$origin=="wild"&live$action=="tag")

returnhatch<-livehatch[sample(nrow(livehatch), hatchreturn), ]
returnesthatch<-liveesthatch[sample(nrow(liveesthatch), hatchreturnest ), ]
returnestwild<-liveestwild[sample(nrow(liveestwild), wildreturnest ), ]
returnmicrohatch<-livemicrohatch[sample(nrow(livemicrohatch), hatchreturnmicro ), ]
returnmicrowild<-livemicrowild[sample(nrow(livemicrowild), wildreturnmicro ), ]

return<-rbind(returnhatch,returnesthatch,returnestwild,returnmicrohatch,returnmicrowild)
#we don't know length at detection so delete
return$fork_length_mm<-rep(NA,nrow(return))

return$action<-rep("detect",length(return$action))
return$stage<-rep("return",length(return$action))

#All fish are assigned to return on a single day per year for simplicity, fish are assigned year of return randomly based on maturity schedule


return1<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510
return2<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365
return3<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365+365
return4<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365+365+365

dates<-(c(rep(return1,maturity2*100),rep(return2,maturity3*100),rep(return3,maturity4*100),rep(return4,maturity5*100)))

return$date<-sample(dates, nrow(return) ,replace=TRUE)


data$date<-as.Date(data$date, format = "%Y-%m-%d",origin="1970-01-01")
return$date<-as.Date(return$date, format = "%Y-%m-%d",origin="1970-01-01")

return<-data.frame(return)
#append returns to dataset
data2021<-rbind(data,return)




































































































##2022

#hatchtag is the number of hatchery tags applied
hatchtag<-5000
#hatchtagdate is the tagging date
hatchtagdate<- "2022-05-10"
#downantdet is the downstream antenna detection efficiency. This is likely quite low in some systems. Here approximated as 6% based on 10% mortality and Nanaimo detects in 2022
downantdet<-.06
#downmort is the mortality between release of hatchery fish and downstream detection. Here arbitrarily assigned as 0.1 which is half of hatchery release to estuary mortality for Pellett Cowichan study
downmort<-.10 
#rivdatest is the start date of river detections
rivdatest<- "2022-05-24"
#rivdatend is the end date of river detection
rivdatend<- "2022-06-19"
#estuarytag is the number of estuary tags applied, for 2022 at Nanaimo and Puntledge for Chinook it was about 2000
estuarytag<-2500
#estuarystockprop is the proportion that is the stock being modelled, based on 2021 genetics this could range from 5% (Punt summer, to 85% Punt Fall)
estuarystockprop<-.5
#estuaryhatchprop<-is the proportion that is the stock being modelled that are hatchery, this could range from 0% (Cowichan RST, to ~80% Punt summer)
estuaryhatchprop<-.5
#estuarytagdatest is the start of estuary tagging
estuarytagdatest<- "2022-06-01"
#estuarytagdatend is the end of estuary tagging
estuarytagdatend<- "2022-06-30"
#estuarydays is the number of tagging days
estuarydays<-8
#estmort is the mortality between detection of hatchery fish on downstream antenna and estuary tagging Here arbritrarily assigned as 0.1, which is half of hatchery release to estuary mortality for Pellett Cowichan study
estmort<-.10
#estuaryhatchrecaprate is the rate of recapture of hatchery fish during estuary tagging, based on a quick look it appears to have ranged from .002 to .004 in 2022 at Nanaimo and Punt
estuaryhatchrecaprate<-.003
#estuarywildmeanFL is the mean fork length which based on 2021 data does not change through June, possibly due to small fish passing through estuary, this value is for puntledge fall run Chinook
estuarywildmeanFL<-75
#estuarywildSDFL the value used here is for puntledge fall run Chinook
estuarywildSDFL<-11
#summort is the mortality between estuary tagging and mid september. Assigned here as 75% based on Cowichan work. Assumes same for wild and hatchery
summort<-.75
#microtagdatest is the start of micro tagging
microtagdatest<- "2022-09-16"
#microtagdatend is the end of micro tagging
microtagdatend<- "2023-04-15"
#microdays is the number of tagging days
microdays<-50
#microcatch is the catch, here based on puntledge in the second year of the study
microcatch<-600
#microcatchsd is the sd in daily catch, here arbitrary. If you increase this way the code is set up it ramps up the catch because catch cannot be 0. Code does not reflect the decline in CPUE that occurs through the season 
microcatchsd<-3
#microhatchprop is the hatchery proportion based on puntledge in second winter
microhatchprop<-0.08
#microdailymort is the daily mortality rate through winter
microdailymort<-0.006
#note that return rates below assume same situation as Cowichan where differential hatchery and wild mortality occurs after first winter and is twice the magnitude for hatchery
#hatchreturn is the absolute return rate on hatchery tags released at hatchery, based roughly on Cowichan Data 
hatchreturn <-0.005
#hatchreturnest is the return rate on hatchery tags applied in estuary, based roughly on Cowichan Data 
hatchreturnest <-hatchreturn/.8
#wildreturnest is the return rate on hatchery tags applied in estuary, based roughly on Cowichan Data 
wildreturnest <-hatchreturnest*2
#hatchreturnmicro is the return rate on hatchery tags applied in mirotrolling, based roughly on Cowichan but increased as tagging occurs later
hatchreturnmicro <-0.05
#wildreturnmicro is the return rate on hatchery tags applied in estuary, based roughly on Cowichan but increased as tagging occurs later
wildreturnmicro <-hatchreturnmicro *2
#maturity2 is the proportion returning as age 2
maturity2<-.1
#maturity3 is the proportion returning as age 3
maturity3<-.4
#maturity4 is the proportion returning as age 4
maturity4<-.4
#maturity5 is the proportion returning as age 5
maturity5<-.1



##Create Hatchery Tagging Data

data2021$tag <- as.numeric(data2021$tag)
tag<-seq(max(data2021$tag)+1,hatchtag+max(data2021$tag),1)
date<-rep(hatchtagdate,hatchtag)
stage<-rep("facility",hatchtag)
origin<-rep("hatch",hatchtag)
fork_length_mm<-rep(NA,hatchtag)
action<-rep("tag",hatchtag)
data<-cbind(tag,date,stage,origin,fork_length_mm,action)
data<-as.data.frame(data)
data$tag<-(as.numeric(data$tag))
data$date<-as.Date(data$date, format = "%Y-%m-%d",origin="1970-01-01")


##Add downstream detects
#kill 10% of fish
#the dataframe "live" constitutes the tags left alive as we move through the stages. For this version mortality is random, not associated with length or origin
live<-subset(data,data$action=="tag")
live<-live[sample(nrow(live), (1-downmort)*nrow(live)), ]
#downdetect is the number of downstream detections
downdetect<-(hatchtag-hatchtag*downmort)*downantdet
#develop vector of days for downstream detections
rivdatest<- as.Date(rivdatest, format = "%Y-%m-%d",origin="1970-01-01")
rivdatest<-as.numeric(rivdatest)
rivdatend<- as.Date(rivdatend, format = "%Y-%m-%d",origin="1970-01-01")
rivdatend<-as.numeric(rivdatend)
days<-seq(rivdatest,rivdatend)
origin<-vector()
origin<-rep("hatch",downdetect)
tag<-sample(live$tag,downdetect,replace=F)
#detections occur randomly through outmigration period.. not really accurate as they would be right skewed
date<-sample(days,downdetect,replace=TRUE)
stage<-rep("downstream",downdetect)
fork_length_mm<-rep(NA,downdetect)
action<-rep("detect",downdetect)
down<-cbind(tag,date,stage,origin,fork_length_mm,action)
down<-as.data.frame(down)
down$date<-as.Date(as.numeric(down$date), format = "%Y-%m-%d",origin="1970-01-01")

#append downstream detections to dataset
data<-rbind(data,down)

##Add Estuary Tagging Data

#develop vector of estuary tagging days, catch is randomly assigned to days
estuarytagdatest<- as.Date(estuarytagdatest, format = "%Y-%m-%d",origin="1970-01-01")
estuarytagdatest<-as.numeric(estuarytagdatest)
estuarytagdatend<- as.Date(estuarytagdatend, format = "%Y-%m-%d",origin="1970-01-01")
estuarytagdatend<-as.numeric(estuarytagdatend)
days<-sample(estuarytagdatest:estuarytagdatend,estuarydays,replace=F)
estuarytag<-estuarytag*estuarystockprop
estuarytag<-estuarytag-estuaryhatchrecaprate*hatchtag


#build estuary wild dataframe
data$tag<-(as.numeric(data$tag))
lengthwildest<-round((1-estuaryhatchprop)*estuarytag)
origin<-rep("wild",lengthwildest)
tag<-seq(max(data$tag)+1,lengthwildest+max(data$tag),1)
date<-sample(days,lengthwildest,replace=TRUE)
stage<-rep("estuary",lengthwildest)
#length is normal around mean and independent of date as seen in the data
fork_length_mm<-round(rnorm(lengthwildest,estuarywildmeanFL,estuarywildSDFL))
action<-rep("tag",lengthwildest)
dataestuarywild<-cbind(tag,date,stage,origin,fork_length_mm,action)
dataestuarywild<-as.data.frame(dataestuarywild)
dataestuarywild$date<-as.Date(as.numeric(dataestuarywild$date), format = "%Y-%m-%d",origin="1970-01-01")
#append wild estuary tagging to data
data<-rbind(data,dataestuarywild)

#build estuary hatch dataframe

##model is for change in hatchery length with date for Punt Qual in spring 2021
mod1<-readRDS("estuaryhatchmod.rds")

data$tag<-(as.numeric(data$tag))
lengthhatchest<-round((estuaryhatchprop)*estuarytag)
origin<-rep("hatch",lengthhatchest)
tag<-seq(max(data$tag)+1,lengthhatchest+max(data$tag),1)
date<-sample(days,lengthhatchest,replace=TRUE)
stage<-rep("estuary",lengthhatchest)
fork_length_mm<-rep(NA,lengthhatchest)
action<-rep("tag",lengthhatchest)
dataestuaryhatch<-cbind(tag,date,stage,origin,fork_length_mm,action)
dataestuaryhatch<-as.data.frame(dataestuaryhatch)
#fork length is simulated by predicting from date model and adding random model residuals
newdata<-dataestuaryhatch
newdata$date<-as.numeric(newdata$date)-364
dataestuaryhatch$fork_length_mm<-predict(mod1,newdata)+sample(resid(mod1),nrow(dataestuaryhatch),replace=T)
dataestuaryhatch$date<-as.Date(as.numeric(dataestuaryhatch$date), format = "%Y-%m-%d",origin="1970-01-01")
#append estuary hatch data
data<-rbind(data,dataestuaryhatch)

#Add estuary hatchery recaps
#kill off another 10% of hatchery fish before recapture
live<-live[sample(nrow(live), (1-estmort)*nrow(live)), ]

estrecap<-(hatchtag*estuaryhatchrecaprate)
origin<-rep("hatch",estrecap)
tag<-sample(live$tag,estrecap,replace=F)
date<-sample(days,estrecap,replace=TRUE)
stage<-rep("estuary",estrecap)
fork_length_mm<-rep(NA,estrecap)
action<-rep("recap",estrecap)

estre<-cbind(tag,date,stage,origin,fork_length_mm,action)
estre<-as.data.frame(estre)
newdata<-estre
newdata$date<-as.numeric(newdata$date)-364
estre$fork_length_mm<-predict(mod1,newdata)+sample(resid(mod1),nrow(estre),replace=T)
estre$date<-as.Date(as.numeric(estre$date), format = "%Y-%m-%d",origin="1970-01-01")
estre

data<-rbind(data,estre)

##Now update live
#first add estuary tags
live<-rbind(live,dataestuaryhatch,dataestuarywild)
#now kill off 75% prior to september
live<-live[sample(nrow(live), (1-summort)*nrow(live)), ]

##Now microtrolling Data

#develop vector of days
microtagdatest<-as.Date(microtagdatest, format = "%Y-%m-%d",origin="1970-01-01")
microtagdatest<-as.numeric(microtagdatest)
microtagdatend<- as.Date(microtagdatend, format = "%Y-%m-%d",origin="1970-01-01")
microtagdatend<-as.numeric(microtagdatend)
days<-sample(microtagdatest:microtagdatend,microdays,replace = F)
days<-sort(days)
#this model is based on punt qual fall Chinook FL by date
mod2<-readRDS("micromod.rds")


for(n in 1:length(days)){
  #create a daily catch
  perday<-round(rnorm(1,microcatch/length(days),microcatchsd))  
  hatch<-round(perday*microhatchprop)
  wild<-round(perday-hatch)
  
  #build daily micro wild dataframe
  data$tag<-(as.numeric(data$tag))
  if(wild>0){
    origin<-rep("wild",wild)
    tag<-seq(max(data$tag)+1,wild+max(data$tag),1)
    date<-rep(days[n],wild)
    stage<-rep("micro",wild)
    fork_length_mm<-fork_length_mm<-rep(NA,wild)
    action<-rep("tag",wild)
    microwild<-cbind(tag,date,stage,origin,fork_length_mm,action)
    microwild<-as.data.frame(microwild)}
  
  #build dail micro hatch dataframe
  if(hatch>0){
    microwild$tag<-as.numeric(microwild$tag)
    origin<-rep("hatch",hatch)
    tag<-seq(max(microwild$tag)+1,hatch+max(microwild$tag),1)
    date<-rep(days[n],hatch)
    stage<-rep("micro",hatch)
    fork_length_mm<-fork_length_mm<-rep(NA,hatch)
    action<-rep("tag",hatch)
    microhatch<-cbind(tag,date,stage,origin,fork_length_mm,action)
    microhatch<-as.data.frame(microhatch)
    dailydata<-rbind(microwild,microhatch)}
  
  
  newdata<-dailydata
  newdata$date<-as.numeric(newdata$date)-364
  dailydata$fork_length_mm<-predict(mod2,newdata)+sample(resid(mod1),nrow(dailydata),replace=T)
  #add daily data 
  dailydata$date<-as.Date(as.numeric(dailydata$date), format = "%Y-%m-%d",origin="1970-01-01")
  
  
  data<-rbind(data,dailydata)
  #iteratively kill off fish since last day based on daily mort rate
  if(n>1){
    interval<-days[n]-days[n-1]
    dailysurvival<-(1-microdailymort)
    deaths<-round(nrow(live)-nrow(live)*dailysurvival^interval)
    live<-live[sample(nrow(live), nrow(live)-deaths), ]}
  #add new fish to live
  live<-rbind(live,dailydata)
  
}


##build returns, these are assigned based on rough return age proportions and the remaining live fish. 
hatchreturn <-hatchreturn*nrow(subset(data,data$stage=="facility"))
hatchreturnest <-round(hatchreturnest*nrow(subset(data,data$stage=="estuary"&data$origin=="hatch"&data$action=="tag")))
wildreturnest <-round(wildreturnest*nrow(subset(data,data$stage=="estuary"&data$origin=="wild"&data$action=="tag")))
hatchreturnmicro <-round(hatchreturnmicro*nrow(subset(data,data$stage=="micro"&data$origin=="hatch"&data$action=="tag")))
wildreturnmicro <-round(wildreturnmicro*nrow(subset(data,data$stage=="micro"&data$origin=="wild"&data$action=="tag")))



livehatch<-subset(live,live$stage=="facility")
liveesthatch<-subset(live,live$stage=="estuary"&live$origin=="hatch"&live$action=="tag")
liveestwild<-subset(live,live$stage=="estuary"&live$origin=="wild"&live$action=="tag")
livemicrohatch<-subset(live,live$stage=="micro"&live$origin=="hatch"&live$action=="tag")
livemicrowild<-subset(live,live$stage=="micro"&live$origin=="wild"&live$action=="tag")

returnhatch<-livehatch[sample(nrow(livehatch), hatchreturn), ]
returnesthatch<-liveesthatch[sample(nrow(liveesthatch), hatchreturnest ), ]
returnestwild<-liveestwild[sample(nrow(liveestwild), wildreturnest ), ]
returnmicrohatch<-livemicrohatch[sample(nrow(livemicrohatch), hatchreturnmicro ), ]
returnmicrowild<-livemicrowild[sample(nrow(livemicrowild), wildreturnmicro ), ]

return<-rbind(returnhatch,returnesthatch,returnestwild,returnmicrohatch,returnmicrowild)
#we don't know length at detection so delete
return$fork_length_mm<-rep(NA,nrow(return))

return$action<-rep("detect",length(return$action))
return$stage<-rep("return",length(return$action))

#All fish are assigned to return on a single day per year for simplicity, fish are assigned year of return randomly based on maturity schedule


return1<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510
return2<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365
return3<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365+365
return4<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365+365+365

dates<-(c(rep(return1,maturity2*100),rep(return2,maturity3*100),rep(return3,maturity4*100),rep(return4,maturity5*100)))

return$date<-sample(dates, nrow(return) ,replace=TRUE)


data$date<-as.Date(data$date, format = "%Y-%m-%d",origin="1970-01-01")
return$date<-as.Date(return$date, format = "%Y-%m-%d",origin="1970-01-01")

return<-data.frame(return)
#append returns to dataset
data2022<-rbind(data,return)








































































































##2023

#hatchtag is the number of hatchery tags applied
hatchtag<-5000
#hatchtagdate is the tagging date
hatchtagdate<- "2023-05-10"
#downantdet is the downstream antenna detection efficiency. This is likely quite low in some systems. Here approximated as 6% based on 10% mortality and Nanaimo detects in 2022
downantdet<-.06
#downmort is the mortality between release of hatchery fish and downstream detection. Here arbitrarily assigned as 0.1 which is half of hatchery release to estuary mortality for Pellett Cowichan study
downmort<-.10 
#rivdatest is the start date of river detections
rivdatest<- "2023-05-24"
#rivdatend is the end date of river detection
rivdatend<- "2023-06-19"
#estuarytag is the number of estuary tags applied, for 2022 at Nanaimo and Puntledge for Chinook it was about 2000
estuarytag<-2500
#estuarystockprop is the proportion that is the stock being modelled, based on 2021 genetics this could range from 5% (Punt summer, to 85% Punt Fall)
estuarystockprop<-.5
#estuaryhatchprop<-is the proportion that is the stock being modelled that are hatchery, this could range from 0% (Cowichan RST, to ~80% Punt summer)
estuaryhatchprop<-.5
#estuarytagdatest is the start of estuary tagging
estuarytagdatest<- "2023-06-01"
#estuarytagdatend is the end of estuary tagging
estuarytagdatend<- "2023-06-30"
#estuarydays is the number of tagging days
estuarydays<-8
#estmort is the mortality between detection of hatchery fish on downstream antenna and estuary tagging Here arbritrarily assigned as 0.1, which is half of hatchery release to estuary mortality for Pellett Cowichan study
estmort<-.10
#estuaryhatchrecaprate is the rate of recapture of hatchery fish during estuary tagging, based on a quick look it appears to have ranged from .002 to .004 in 2022 at Nanaimo and Punt
estuaryhatchrecaprate<-.003
#estuarywildmeanFL is the mean fork length which based on 2021 data does not change through June, possibly due to small fish passing through estuary, this value is for puntledge fall run Chinook
estuarywildmeanFL<-75
#estuarywildSDFL the value used here is for puntledge fall run Chinook
estuarywildSDFL<-11
#summort is the mortality between estuary tagging and mid september. Assigned here as 75% based on Cowichan work. Assumes same for wild and hatchery
summort<-.75
#microtagdatest is the start of micro tagging
microtagdatest<- "2023-09-16"
#microtagdatend is the end of micro tagging
microtagdatend<- "2024-04-15"
#microdays is the number of tagging days
microdays<-50
#microcatch is the catch, here based on puntledge in the second year of the study
microcatch<-600
#microcatchsd is the sd in daily catch, here arbitrary. If you increase this way the code is set up it ramps up the catch because catch cannot be 0. Code does not reflect the decline in CPUE that occurs through the season 
microcatchsd<-3
#microhatchprop is the hatchery proportion based on puntledge in second winter
microhatchprop<-0.08
#microdailymort is the daily mortality rate through winter
microdailymort<-0.006
#note that return rates below assume same situation as Cowichan where differential hatchery and wild mortality occurs after first winter and is twice the magnitude for hatchery
#hatchreturn is the absolute return rate on hatchery tags released at hatchery, based roughly on Cowichan Data 
hatchreturn <-0.005
#hatchreturnest is the return rate on hatchery tags applied in estuary, based roughly on Cowichan Data 
hatchreturnest <-hatchreturn/.8
#wildreturnest is the return rate on hatchery tags applied in estuary, based roughly on Cowichan Data 
wildreturnest <-hatchreturnest*2
#hatchreturnmicro is the return rate on hatchery tags applied in mirotrolling, based roughly on Cowichan but increased as tagging occurs later
hatchreturnmicro <-0.05
#wildreturnmicro is the return rate on hatchery tags applied in estuary, based roughly on Cowichan but increased as tagging occurs later
wildreturnmicro <-hatchreturnmicro *2
#maturity2 is the proportion returning as age 2
maturity2<-.1
#maturity3 is the proportion returning as age 3
maturity3<-.4
#maturity4 is the proportion returning as age 4
maturity4<-.4
#maturity5 is the proportion returning as age 5
maturity5<-.1



##Create Hatchery Tagging Data

data2022$tag <- as.numeric(data2022$tag)
tag<-seq(max(data2022$tag)+1,hatchtag+max(data2022$tag),1)
date<-rep(hatchtagdate,hatchtag)
stage<-rep("facility",hatchtag)
origin<-rep("hatch",hatchtag)
fork_length_mm<-rep(NA,hatchtag)
action<-rep("tag",hatchtag)
data<-cbind(tag,date,stage,origin,fork_length_mm,action)
data<-as.data.frame(data)
data$tag<-(as.numeric(data$tag))
data$date<-as.Date(data$date, format = "%Y-%m-%d",origin="1970-01-01")


##Add downstream detects
#kill 10% of fish
#the dataframe "live" constitutes the tags left alive as we move through the stages. For this version mortality is random, not associated with length or origin
live<-subset(data,data$action=="tag")
live<-live[sample(nrow(live), (1-downmort)*nrow(live)), ]
#downdetect is the number of downstream detections
downdetect<-(hatchtag-hatchtag*downmort)*downantdet
#develop vector of days for downstream detections
rivdatest<- as.Date(rivdatest, format = "%Y-%m-%d",origin="1970-01-01")
rivdatest<-as.numeric(rivdatest)
rivdatend<- as.Date(rivdatend, format = "%Y-%m-%d",origin="1970-01-01")
rivdatend<-as.numeric(rivdatend)
days<-seq(rivdatest,rivdatend)
origin<-vector()
origin<-rep("hatch",downdetect)
tag<-sample(live$tag,downdetect,replace=F)
#detections occur randomly through outmigration period.. not really accurate as they would be right skewed
date<-sample(days,downdetect,replace=TRUE)
stage<-rep("downstream",downdetect)
fork_length_mm<-rep(NA,downdetect)
action<-rep("detect",downdetect)
down<-cbind(tag,date,stage,origin,fork_length_mm,action)
down<-as.data.frame(down)
down$date<-as.Date(as.numeric(down$date), format = "%Y-%m-%d",origin="1970-01-01")

#append downstream detections to dataset
data<-rbind(data,down)

##Add Estuary Tagging Data

#develop vector of estuary tagging days, catch is randomly assigned to days
estuarytagdatest<- as.Date(estuarytagdatest, format = "%Y-%m-%d",origin="1970-01-01")
estuarytagdatest<-as.numeric(estuarytagdatest)
estuarytagdatend<- as.Date(estuarytagdatend, format = "%Y-%m-%d",origin="1970-01-01")
estuarytagdatend<-as.numeric(estuarytagdatend)
days<-sample(estuarytagdatest:estuarytagdatend,estuarydays,replace=F)
estuarytag<-estuarytag*estuarystockprop
estuarytag<-estuarytag-estuaryhatchrecaprate*hatchtag


#build estuary wild dataframe
data$tag<-(as.numeric(data$tag))
lengthwildest<-round((1-estuaryhatchprop)*estuarytag)
origin<-rep("wild",lengthwildest)
tag<-seq(max(data$tag)+1,lengthwildest+max(data$tag),1)
date<-sample(days,lengthwildest,replace=TRUE)
stage<-rep("estuary",lengthwildest)
#length is normal around mean and independent of date as seen in the data
fork_length_mm<-round(rnorm(lengthwildest,estuarywildmeanFL,estuarywildSDFL))
action<-rep("tag",lengthwildest)
dataestuarywild<-cbind(tag,date,stage,origin,fork_length_mm,action)
dataestuarywild<-as.data.frame(dataestuarywild)
dataestuarywild$date<-as.Date(as.numeric(dataestuarywild$date), format = "%Y-%m-%d",origin="1970-01-01")
#append wild estuary tagging to data
data<-rbind(data,dataestuarywild)

#build estuary hatch dataframe

##model is for change in hatchery length with date for Punt Qual in spring 2021
mod1<-readRDS("estuaryhatchmod.rds")

data$tag<-(as.numeric(data$tag))
lengthhatchest<-round((estuaryhatchprop)*estuarytag)
origin<-rep("hatch",lengthhatchest)
tag<-seq(max(data$tag)+1,lengthhatchest+max(data$tag),1)
date<-sample(days,lengthhatchest,replace=TRUE)
stage<-rep("estuary",lengthhatchest)
fork_length_mm<-rep(NA,lengthhatchest)
action<-rep("tag",lengthhatchest)
dataestuaryhatch<-cbind(tag,date,stage,origin,fork_length_mm,action)
dataestuaryhatch<-as.data.frame(dataestuaryhatch)
#fork length is simulated by predicting from date model and adding random model residuals
newdata<-dataestuaryhatch
newdata$date<-as.numeric(newdata$date)-364
dataestuaryhatch$fork_length_mm<-predict(mod1,newdata)+sample(resid(mod1),nrow(dataestuaryhatch),replace=T)
dataestuaryhatch$date<-as.Date(as.numeric(dataestuaryhatch$date), format = "%Y-%m-%d",origin="1970-01-01")
#append estuary hatch data
data<-rbind(data,dataestuaryhatch)

#Add estuary hatchery recaps
#kill off another 10% of hatchery fish before recapture
live<-live[sample(nrow(live), (1-estmort)*nrow(live)), ]

estrecap<-(hatchtag*estuaryhatchrecaprate)
origin<-rep("hatch",estrecap)
tag<-sample(live$tag,estrecap,replace=F)
date<-sample(days,estrecap,replace=TRUE)
stage<-rep("estuary",estrecap)
fork_length_mm<-rep(NA,estrecap)
action<-rep("recap",estrecap)

estre<-cbind(tag,date,stage,origin,fork_length_mm,action)
estre<-as.data.frame(estre)
newdata<-estre
newdata$date<-as.numeric(newdata$date)-364
estre$fork_length_mm<-predict(mod1,newdata)+sample(resid(mod1),nrow(estre),replace=T)
estre$date<-as.Date(as.numeric(estre$date), format = "%Y-%m-%d",origin="1970-01-01")
estre

data<-rbind(data,estre)

##Now update live
#first add estuary tags
live<-rbind(live,dataestuaryhatch,dataestuarywild)
#now kill off 75% prior to september
live<-live[sample(nrow(live), (1-summort)*nrow(live)), ]

##Now microtrolling Data

#develop vector of days
microtagdatest<-as.Date(microtagdatest, format = "%Y-%m-%d",origin="1970-01-01")
microtagdatest<-as.numeric(microtagdatest)
microtagdatend<- as.Date(microtagdatend, format = "%Y-%m-%d",origin="1970-01-01")
microtagdatend<-as.numeric(microtagdatend)
days<-sample(microtagdatest:microtagdatend,microdays,replace = F)
days<-sort(days)
#this model is based on punt qual fall Chinook FL by date
mod2<-readRDS("micromod.rds")


for(n in 1:length(days)){
  #create a daily catch
  perday<-round(rnorm(1,microcatch/length(days),microcatchsd))  
  hatch<-round(perday*microhatchprop)
  wild<-round(perday-hatch)
  
  #build daily micro wild dataframe
  data$tag<-(as.numeric(data$tag))
  if(wild>0){
    origin<-rep("wild",wild)
    tag<-seq(max(data$tag)+1,wild+max(data$tag),1)
    date<-rep(days[n],wild)
    stage<-rep("micro",wild)
    fork_length_mm<-fork_length_mm<-rep(NA,wild)
    action<-rep("tag",wild)
    microwild<-cbind(tag,date,stage,origin,fork_length_mm,action)
    microwild<-as.data.frame(microwild)}
  
  #build dail micro hatch dataframe
  if(hatch>0){
    microwild$tag<-as.numeric(microwild$tag)
    origin<-rep("hatch",hatch)
    tag<-seq(max(microwild$tag)+1,hatch+max(microwild$tag),1)
    date<-rep(days[n],hatch)
    stage<-rep("micro",hatch)
    fork_length_mm<-fork_length_mm<-rep(NA,hatch)
    action<-rep("tag",hatch)
    microhatch<-cbind(tag,date,stage,origin,fork_length_mm,action)
    microhatch<-as.data.frame(microhatch)
    dailydata<-rbind(microwild,microhatch)}
  
  
  newdata<-dailydata
  newdata$date<-as.numeric(newdata$date)-364
  dailydata$fork_length_mm<-predict(mod2,newdata)+sample(resid(mod1),nrow(dailydata),replace=T)
  #add daily data 
  dailydata$date<-as.Date(as.numeric(dailydata$date), format = "%Y-%m-%d",origin="1970-01-01")
  
  
  data<-rbind(data,dailydata)
  #iteratively kill off fish since last day based on daily mort rate
  if(n>1){
    interval<-days[n]-days[n-1]
    dailysurvival<-(1-microdailymort)
    deaths<-round(nrow(live)-nrow(live)*dailysurvival^interval)
    live<-live[sample(nrow(live), nrow(live)-deaths), ]}
  #add new fish to live
  live<-rbind(live,dailydata)
  
}


##build returns, these are assigned based on rough return age proportions and the remaining live fish. 
hatchreturn <-hatchreturn*nrow(subset(data,data$stage=="facility"))
hatchreturnest <-round(hatchreturnest*nrow(subset(data,data$stage=="estuary"&data$origin=="hatch"&data$action=="tag")))
wildreturnest <-round(wildreturnest*nrow(subset(data,data$stage=="estuary"&data$origin=="wild"&data$action=="tag")))
hatchreturnmicro <-round(hatchreturnmicro*nrow(subset(data,data$stage=="micro"&data$origin=="hatch"&data$action=="tag")))
wildreturnmicro <-round(wildreturnmicro*nrow(subset(data,data$stage=="micro"&data$origin=="wild"&data$action=="tag")))



livehatch<-subset(live,live$stage=="facility")
liveesthatch<-subset(live,live$stage=="estuary"&live$origin=="hatch"&live$action=="tag")
liveestwild<-subset(live,live$stage=="estuary"&live$origin=="wild"&live$action=="tag")
livemicrohatch<-subset(live,live$stage=="micro"&live$origin=="hatch"&live$action=="tag")
livemicrowild<-subset(live,live$stage=="micro"&live$origin=="wild"&live$action=="tag")

returnhatch<-livehatch[sample(nrow(livehatch), hatchreturn), ]
returnesthatch<-liveesthatch[sample(nrow(liveesthatch), hatchreturnest ), ]
returnestwild<-liveestwild[sample(nrow(liveestwild), wildreturnest ), ]
returnmicrohatch<-livemicrohatch[sample(nrow(livemicrohatch), hatchreturnmicro ), ]
returnmicrowild<-livemicrowild[sample(nrow(livemicrowild), wildreturnmicro ), ]

return<-rbind(returnhatch,returnesthatch,returnestwild,returnmicrohatch,returnmicrowild)
#we don't know length at detection so delete
return$fork_length_mm<-rep(NA,nrow(return))

return$action<-rep("detect",length(return$action))
return$stage<-rep("return",length(return$action))

#All fish are assigned to return on a single day per year for simplicity, fish are assigned year of return randomly based on maturity schedule


return1<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510
return2<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365
return3<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365+365
return4<-as.numeric(as.Date(hatchtagdate, format = "%Y-%m-%d",origin="1970-01-01"))+510+365+365+365

dates<-(c(rep(return1,maturity2*100),rep(return2,maturity3*100),rep(return3,maturity4*100),rep(return4,maturity5*100)))

return$date<-sample(dates, nrow(return) ,replace=TRUE)


data$date<-as.Date(data$date, format = "%Y-%m-%d",origin="1970-01-01")
return$date<-as.Date(return$date, format = "%Y-%m-%d",origin="1970-01-01")

return<-data.frame(return)
#append returns to dataset
data2023<-rbind(data,return)



finaldata <- rbind(data2021, data2022, data2023)



write.csv(finaldata, "finaldata.csv")

