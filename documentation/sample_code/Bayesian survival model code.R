

library(devtools)
library(postpack)
library(coda)
library(remotes)
library(rjags)
library(telemetyr)
library(dplyr)
library(ggplot2)
library(anchors)
library(lubridate)
library(car)
library(lme4)
library(FactoMineR)
library(factoextra)
library(corrplot)
library(gridExtra)
library(mvnormtest)
library(MVN)
library(vegan)
library(permute)
library(lattice)
library(emmeans)
library(tidyr)
library(cluster)
library(ggrepel)
library(lmerTest)
library(survival)
library(survminer)
library(MuMIn)
library(CRM)
library(TMB)
library(RMark)
library(marked)
library(mra)
library(tidyverse)
library(mark)
library(knitr)
library(MCMCvis)

# knitr options
knitr::opts_chunk$set(
  collapse = TRUE,
  warning = FALSE,
  message = FALSE,
  echo = TRUE,
  comment = "#>"
)


##


#########First prep the simulated PIT data


## Load dataset

getwd()
survdata <- read.delim("/Users/lauraelmer/Library/CloudStorage/Dropbox-BCSRIFBottlenecks/Laura Elmer/PSF bottlenecks/Kevin Pellett_Cowichan data/Cowichan detection histories_LKE.txt")
head(survdata)


survdata$stage<-as.factor(survdata$stage)
survdata$origin<-as.factor(survdata$origin)
survdata$year<-as.factor(survdata$year)
survdata$stock_1<-as.factor(survdata$stock_1)



sum(survdata$year == "2013")
sum(survdata$year == "2014")
sum(survdata$year == "2015")
sum(survdata$year == "2016")
sum(survdata$year == "2017")
sum(survdata$year == "2018")
sum(survdata$year == "2019")
sum(survdata$year == "2020")


## Create two separate datasets for wild vs hatchery fish


wildsurv <- survdata[which(substr(survdata$origin,1,1)=="W"),] 


sum(wildsurv$year == "2014")
sum(wildsurv$year == "2015")
sum(wildsurv$year == "2016")
sum(wildsurv$year == "2017")
sum(wildsurv$year == "2018")
sum(wildsurv$year == "2019")


hatchsurv <- survdata[which(substr(survdata$origin,1,1)=="H"),] 


sum(hatchsurv$year == "2014")
sum(hatchsurv$year == "2015")
sum(hatchsurv$year == "2016")
sum(hatchsurv$year == "2017")
sum(hatchsurv$year == "2018")
sum(hatchsurv$year == "2019")


#hatchsurv <- hatchsurv[which(substr(hatchsurv$year,1,4)=="2014"),] 
#wildsurv <- wildsurv[which(substr(wildsurv$year,1,4)=="2014"),] 
hatchsurv <- hatchsurv[which(substr(hatchsurv$year,1,4)=="2016"),] 
wildsurv <- wildsurv[which(substr(wildsurv$year,1,4)=="2016"),] 


hatchsurv$t6 <- as.integer(hatchsurv$t6a|hatchsurv$t7b)
#hatchsurv$t7 <- hatchsurv$t6


## let's just work with HATCHERY FISH to start with

hatchtotal <- hatchsurv

hatchtotal$t1 <- as.factor(hatchtotal$t1)
hatchtotal$t2 <- as.factor(hatchtotal$t2)
hatchtotal$t3 <- as.factor(hatchtotal$t3)
hatchtotal$t4 <- as.factor(hatchtotal$t4)
#hatchtotal$t5 <- as.factor(hatchtotal$t5)
hatchtotal$t6 <- as.factor(hatchtotal$t6)
#hatchtotal$t7 <- as.factor(hatchtotal$t7)


#hatchtotal$ch <- paste(hatchtotal$t1, hatchtotal$t2, hatchtotal$t3, hatchtotal$t4, hatchtotal$t5, hatchtotal$t6, sep = "")
#hatchtotal$ch <- paste(hatchtotal$t1, hatchtotal$t2, hatchtotal$t3, hatchtotal$t4, hatchtotal$t6, sep = "")
hatchtotal$ch <- paste(hatchtotal$t1, hatchtotal$t2, hatchtotal$t3, hatchtotal$t4, hatchtotal$t6, sep = "")



head(hatchtotal)

#rename some columns
names(hatchtotal)[names(hatchtotal) == "id"] <- "tag_id"
names(hatchtotal)[names(hatchtotal) == "ch"] <- "cap_hist"
hatchtotal$duty_cycle <- "batch_1"
head(hatchtotal)


##Remove non-Cowichan fish



hatchtotal$tag_id<-as.numeric(as.character(hatchtotal$tag_id))
hatchtotal$t1<-as.numeric(as.character(hatchtotal$t1))
hatchtotal$t2<-as.numeric(as.character(hatchtotal$t2))
hatchtotal$t3<-as.numeric(as.character(hatchtotal$t3))
hatchtotal$t4<-as.numeric(as.character(hatchtotal$t4))
hatchtotal$t5<-hatchtotal$t6
hatchtotal$t5<-as.numeric(as.character(hatchtotal$t5))
#hatchtotal$t6<-as.numeric(as.character(hatchtotal$t6))
#hatchtotal$t7<-as.numeric(as.character(hatchtotal$t7))
head(hatchtotal)


##Remove fish that have a capture history of 0000000 (why do they have this capture history??)
hatchtotal = hatchtotal[hatchtotal$cap_hist != "00000" , ]
#hatchtotal = hatchtotal[hatchtotal$cap_hist != "0000000" , ]
hatchtotal = hatchtotal[hatchtotal$cap_hist != "00001" , ]


#Make a simpler dataset with just the columns we want
#hatchsimple <- hatchtotal[c(1, 23, 15:19)]
hatchsimple <- hatchtotal[c(1, 23, 15:19)]
#hatchsimple <- hatchtotal[c(1, 24, 15:19,22:23)]
head(hatchsimple)
head(hatchtotal)

hatchsum <- hatchsimple %>%
  group_by(t1, t2, t3, t4, t5, cap_hist) %>%
  summarise(freq = n()) 

hatchsum

#hatchsimple %>%
  #group_by(t1, t2, t3, t4, t5, t6, t7, cap_hist) %>%
  #summarise(freq = n()) %>%
  #kable()

##






#To step through fitting this Bayesian CJS model, first we specify the JAGS model. 
#For this example, we will fit a model with different detection probabilities for each site, and different survival probabilities between each site. 
#We will also calculate the cumulative survival up to each site. 
#We write this model as a text file, as shown below. 
#The telemetyr package has a function to write this model, called write_bayes_cjs, where the user must specify the file path to save this text file.

write_bayes_cjs = function(file_path = NULL) {
  
  if(is.null(file_path)) file_path = 'CJS_model.txt'
  
  # specify model in JAGS
  jags_model = function() {
    
    
    
    # PRIORS AND CONSTRAINTS
    
    phi[1] <- 1
    p[1] <- 1
    
    for(j in 2:J) {
      phi[j] ~ dbeta(1,1) # survival probability between arrays
    }
    
    for(j in 2:(J-1)) {
      p[j] ~ dbeta(1,1) # detection probability between arrays
    }
    
    p[J] <- 0.95  # this constrains the model and allows user to input the known detection efficiency of final PIT receiver
    
    
    #phi[1] <- 1
    #p[1] <- 1
    
    #phi[2] ~ dbeta(7,3)
    #p[2] ~ dbeta(1,1)
    
    #phi[3] ~ dbeta(9, 1)
    #p[3] ~ dbeta(1,1)
    
    #phi[4] ~ dbeta(6, 4)
    #p[4] ~ dbeta(1,1)
    
    #phi[5] ~ dbeta(1, 9)
    #p[5] <- 0.95
    
 
    
    
    
    
    # LIKELIHOOD - Here, p and phi are global
    for (i in 1:N) {
      # j = f[i] is the release occasion - known alive; i.e., the mark event
      for (j in (f[i] + 1):J) {
        # survival process: must have been alive in j-1 to have non-zero pr(alive at j)
        z[i,j] ~ dbern(phi[j] * z[i,j-1]) # fish i in period j is a bernoulli trial
        
        # detection process: must have been alive in j to observe in j
        y[i,j] ~ dbern(p[j] * z[i,j]) # another bernoulli trial
      }
    }
    
    
    
    # DERIVED QUANTITIES
    # survivorship is probability of surviving from release to a detection occasion
    survship[1] <- 1 # the mark event; everybody survived to this point
    for (j in 2:J) { # the rest of the events
      survship[j] <- survship[j-1] * phi[j]
    }
  }
  
  postpack::write_model(jags_model, file_path)
}



write_bayes_cjs(file_path = 'CJS_model2.txt')


#Next, we must prepare our data for this model, which is done using the function prep_jags_cjs(), which prepares a named list of data to feed to JAGS

jags_data = prep_jags_cjs(
  cap_hist_wide = hatchsimple,
  tag_meta = hatchtotal,
  drop_col_nm = "duty_cycle",
  drop_values = c("batch_2", "batch_3")
)





#The model requires several pieces of data:

##  $N$: the number of tags used in the model
##  $J$: the number of detection points, including the release site
##  $y$: the $N \times J$ matrix of capture histories
##  $z$: an $N \times J$ matrix of times each fish was known to be alive
##  $f$: a vector of length $N$ showing the first occasion each individual is known to be alive


# The next step is to run the MCMC algorithm. We use the rjags package to connect R to JAGS and extract samples from the posteriors of each parameter, and do this with the function run_jags_cjs().

cjs_post = run_jags_cjs(file_path = 'CJS_model2.txt',
                        jags_data = jags_data,
                        n_chains = 4,
                        n_adapt = 1000,
                        n_burnin = 2500,
                        n_iter = 2500,
                        n_thin = 5,
                        params_to_save = c("phi", "p", "survship"),
                        rng_seed = 4)



# Finally, we summarise the posterior samples with the function summarise_jags_cjs. This uses the package postpack to create summaries of each parameter, and there are several inputs the user can adjust depending on what they would like to extract. If you use the wrapper fit_bayes_cjs() function, the site names are added to this summary dataframe, but a user could do the same by hand, using code like that listed below.

param_summ = summarise_jags_cjs(cjs_post)
param_summ




param_summ %<>%
  left_join(tibble(site = colnames(jags_data$y)) %>%
              mutate(site = factor(site, levels = site),
                     site_num = as.integer(site))) %>%
  select(param_grp, site_num,
         site,
         param,
         everything())


surv_p = param_summ %>%
  filter(param_grp == 'survship') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Cumulative Survival')+
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("River", "Beach seine", "Purse seine", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

phi_p = param_summ %>%
  filter(param_grp == 'phi') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Survival From Previous Site')+
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("River", "Beach seine", "Purse seine", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

det_p = param_summ %>%
  filter(param_grp == 'p') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Detection Probability')+
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("River", "Beach seine", "Purse seine", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))


det_p
phi_p
surv_p


ggarrange(det_p, phi_p, surv_p,
          labels = c("A", "B", "C"),
          ncol = 3, nrow = 1)



postpack::diag_plots(cjs_post, "phi",
                     layout = "5x3")
postpack::diag_plots(cjs_post, "survship",
                     layout = "5x3")
postpack::diag_plots(cjs_post, "^p[",
                     layout = "5x3")


curve(dbeta(x, shape1 = 9, shape2 = 1), from = 0, to = 1, 
      main = "Beta Distribution", xlab = "x", ylab = "Density")


PR <- rbeta(5000, 1,1)
MCMCtrace(cjs_post, params = 'phi', priors = PR, Rhat = T, n.eff = T,  ind = TRUE, pdf = FALSE)

PR <- rbeta(5000, 7,3)
MCMCtrace(cjs_post, params = 'phi', priors = PR, Rhat = T, n.eff = T,  ind = TRUE, pdf = FALSE)

PR <- rbeta(5000, 9,1)
MCMCtrace(cjs_post, params = 'phi', priors = PR, Rhat = T, n.eff = T,  ind = TRUE, pdf = FALSE)

PR <- rbeta(5000, 6,4)
MCMCtrace(cjs_post, params = 'phi', priors = PR, Rhat = T, n.eff = T,  ind = TRUE, pdf = FALSE)

PR <- rbeta(5000, 1,9)
MCMCtrace(cjs_post, params = 'phi', priors = PR, Rhat = T, n.eff = T,  ind = TRUE, pdf = FALSE)




MCMCtrace(cjs_post, params = 'p', priors = PR, Rhat = T, n.eff = T, exact = TRUE, ind = TRUE, pdf = FALSE)
MCMCtrace(cjs_post, params = 'phi', priors = PR, Rhat = T, n.eff = T, exact = TRUE, ind = TRUE, pdf = FALSE)
MCMCtrace(cjs_post, params = 'survship', priors = PR, Rhat = T, n.eff = T, exact = TRUE, ind = TRUE, pdf = FALSE)


plot(hatchtotal$t2)
densityplot(hatchtotal$t2)

postpack::get_params(cjs_post)
postpack::post_dim(cjs_post)
postpack::post_summ(cjs_post, "phi")
postpack::post_summ(cjs_post, "p")
postpack::post_summ(cjs_post, "survship")

postpack::post_summ(cjs_post)




data(cjs_post)
head(cjs_post)
PR <- rbeta(2000, 10,100)
curve(dbeta(x, shape1 = 10, shape2 = 90), from = 0, to = 1, 
      main = "Beta Distribution", xlab = "x", ylab = "Density")

MCMCtrace(cjs_post, params = 'phi', priors = PR, exact = TRUE, ind = TRUE, pdf = FALSE)


# Creating the Sequence
gfg = seq(0, 1, by = 0.1)

# Plotting the beta density
plot(gfg, dbeta(gfg, 2,3), xlab="X",
     ylab = "Beta Density", type = "l",
     col = "Red")


head(MCMC_data)
head(cjs_post)


set.seed(182)
nsims <- 1000
PR <- rbeta(nsims, 1,1)

simd <- tibble(prop = (hatchtotal$t1-mean(hatchtotal$t1))/sd(hatchtotal$t1))

for(i in 1:nsims){
  this_mu <- beta0[i] + beta1[i]*simd$prop 
  simd[paste0(i)] <- this_mu + rnorm(nrow(simd), 0, sigma[i])
}

## Prior predictive checks
set.seed(182)
nsims <- 100
sigma <- 1 / sqrt(rgamma(nsims, 1, rate = 100))
beta0 <- rnorm(nsims, 1,1)
beta1 <- rnorm(nsims, 1,1)


dsims <- tibble(log_gest_c = (log(ds$gest)-mean(log(ds$gest)))/sd(log(ds$gest)))

for(i in 1:nsims){
  this_mu <- beta0[i] + beta1[i]*dsims$log_gest_c 
  dsims[paste0(i)] <- this_mu + rnorm(nrow(dsims), 0, sigma[i])
}

dsl <- simd %>% 
  pivot_longer(`1`:`10`, names_to = "sim", values_to = "sim_weight")

dsl %>% 
  ggplot(aes(sim_weight)) + geom_histogram(aes(y = ..density..), bins = 20, fill = "turquoise", color = "black") + 
  xlim(c(-1000, 1000)) + 
  geom_vline(xintercept = log(60), color = "purple", lwd = 1.2, lty = 2) + 
  theme_bw(base_size = 16) + 
  annotate("text", x=300, y=0.0022, label= "Monica's\ncurrent weight", 
           color = "purple", size = 5) 





# Sample 10000 draws from Beta(45,55) prior
prior_A <- rbeta(n = 50000, shape1 = 60, shape2 = 40)

# Store the results in a data frame
prior_sim <- data.frame(prior_A)

# Construct a density plot of the prior sample
ggplot(prior_sim, aes(x = prior_A)) + 
  geom_density()
##



































##WILD FISH








wildsurv <- survdata[which(substr(survdata$origin,1,1)=="W"),] 
hatchsurv <- survdata[which(substr(survdata$origin,1,1)=="H"),] 
#hatchsurv <- hatchsurv[which(substr(hatchsurv$year,1,4)=="2015"),] 
#wildsurv <- wildsurv[which(substr(wildsurv$year,1,4)=="2015"),] 
hatchsurv <- hatchsurv[which(substr(hatchsurv$year,1,4)=="2016"),] 
wildsurv <- wildsurv[which(substr(wildsurv$year,1,4)=="2016"),] 


wildsurv$t6 <- as.integer(wildsurv$t6a|wildsurv$t7b)
#hatchsurv$t7 <- hatchsurv$t6


## let's just work with WILD FISH to start with

wildtotal <- wildsurv

wildtotal$t1 <- as.factor(wildtotal$t1)
wildtotal$t2 <- as.factor(wildtotal$t2)
wildtotal$t3 <- as.factor(wildtotal$t3)
wildtotal$t4 <- as.factor(wildtotal$t4)
#hatchtotal$t5 <- as.factor(hatchtotal$t5)
wildtotal$t6 <- as.factor(wildtotal$t6)
#hatchtotal$t7 <- as.factor(hatchtotal$t7)


#hatchtotal$ch <- paste(hatchtotal$t1, hatchtotal$t2, hatchtotal$t3, hatchtotal$t4, hatchtotal$t5, hatchtotal$t6, sep = "")
#wildtotal$ch <- paste(wildtotal$t1, wildtotal$t2, wildtotal$t3, wildtotal$t4, wildtotal$t6, sep = "")
wildtotal$ch <- paste(wildtotal$t1, wildtotal$t2, wildtotal$t3, wildtotal$t4, wildtotal$t6, sep = "")




head(wildtotal)

#rename some columns
names(wildtotal)[names(wildtotal) == "id"] <- "tag_id"
names(wildtotal)[names(wildtotal) == "ch"] <- "cap_hist"
wildtotal$duty_cycle <- "batch_1"
head(wildtotal)


##Remove non-Cowichan fish



wildtotal$tag_id<-as.numeric(as.character(wildtotal$tag_id))
wildtotal$t1<-as.numeric(as.character(wildtotal$t1))
wildtotal$t2<-as.numeric(as.character(wildtotal$t2))
wildtotal$t3<-as.numeric(as.character(wildtotal$t3))
wildtotal$t4<-as.numeric(as.character(wildtotal$t4))
wildtotal$t5<-wildtotal$t6
wildtotal$t5<-as.numeric(as.character(wildtotal$t5))
#hatchtotal$t6<-as.numeric(as.character(hatchtotal$t6))
#hatchtotal$t7<-as.numeric(as.character(hatchtotal$t7))
head(wildtotal)


##Remove fish that have a capture history of 0000000 (why do they have this capture history??)
wildtotal = wildtotal[wildtotal$cap_hist != "00000" , ]
#hatchtotal = hatchtotal[hatchtotal$cap_hist != "0000000" , ]
wildtotal = wildtotal[wildtotal$cap_hist != "00001" , ]


#Make a simpler dataset with just the columns we want
wildsimple <- wildtotal[c(1, 23, 15:19)]
#hatchsimple <- hatchtotal[c(1, 24, 15:19,22:23)]
head(wildsimple)
head(wildtotal)

wildsum <- wildsimple %>%
  group_by(t1, t2, t3, t4, t5, cap_hist) %>%
  summarise(freq = n()) 

wildsum

#hatchsimple %>%
#group_by(t1, t2, t3, t4, t5, t6, t7, cap_hist) %>%
#summarise(freq = n()) %>%
#kable()

##






#To step through fitting this Bayesian CJS model, first we specify the JAGS model. 
#For this example, we will fit a model with different detection probabilities for each site, and different survival probabilities between each site. 
#We will also calculate the cumulative survival up to each site. 
#We write this model as a text file, as shown below. 
#The telemetyr package has a function to write this model, called write_bayes_cjs, where the user must specify the file path to save this text file.

write_bayes_cjs = function(file_path = NULL) {
  
  if(is.null(file_path)) file_path = 'CJS_model.txt'
  
  # specify model in JAGS
  jags_model = function() {
    
    
    
    # PRIORS AND CONSTRAINTS
    phi[1] <- 1
    p[1] <- 1
    
    for(j in 2:J) {
      phi[j] ~ dbeta(1,1) # survival probability between arrays
    }
    
    for(j in 2:(J-1)) {
      p[j] ~ dbeta(1,1) # survival probability between arrays
    }
    
    p[J] <- 1  # this constrains the model and allows user to input the known detection efficiency of final PIT receiver
    
    
    
    
    
    
    # LIKELIHOOD - Here, p and phi are global
    for (i in 1:N) {
      # j = f[i] is the release occasion - known alive; i.e., the mark event
      for (j in (f[i] + 1):J) {
        # survival process: must have been alive in j-1 to have non-zero pr(alive at j)
        z[i,j] ~ dbern(phi[j] * z[i,j-1]) # fish i in period j is a bernoulli trial
        
        # detection process: must have been alive in j to observe in j
        y[i,j] ~ dbern(p[j] * z[i,j]) # another bernoulli trial
      }
    }
    
    
    
    # DERIVED QUANTITIES
    # survivorship is probability of surviving from release to a detection occasion
    survship[1] <- 1 # the mark event; everybody survived to this point
    for (j in 2:J) { # the rest of the events
      survship[j] <- survship[j-1] * phi[j]
    }
  }
  
  postpack::write_model(jags_model, file_path)
}



write_bayes_cjs(file_path = 'CJS_model2.txt')


#Next, we must prepare our data for this model, which is done using the function prep_jags_cjs(), which prepares a named list of data to feed to JAGS

jags_data2 = prep_jags_cjs(
  cap_hist_wide = wildsimple,
  tag_meta = wildtotal,
  drop_col_nm = "duty_cycle",
  drop_values = c("batch_2", "batch_3")
)





#The model requires several pieces of data:

##  $N$: the number of tags used in the model
##  $J$: the number of detection points, including the release site
##  $y$: the $N \times J$ matrix of capture histories
##  $z$: an $N \times J$ matrix of times each fish was known to be alive
##  $f$: a vector of length $N$ showing the first occasion each individual is known to be alive


# The next step is to run the MCMC algorithm. We use the rjags package to connect R to JAGS and extract samples from the posteriors of each parameter, and do this with the function run_jags_cjs().

cjs_post2 = run_jags_cjs(file_path = 'CJS_model2.txt',
                        jags_data = jags_data2,
                        n_chains = 4,
                        n_adapt = 1000,
                        n_burnin = 2500,
                        n_iter = 2500,
                        n_thin = 5,
                        params_to_save = c("phi", "p", "survship"),
                        rng_seed = 4)



# Finally, we summarise the posterior samples with the function summarise_jags_cjs. This uses the package postpack to create summaries of each parameter, and there are several inputs the user can adjust depending on what they would like to extract. If you use the wrapper fit_bayes_cjs() function, the site names are added to this summary dataframe, but a user could do the same by hand, using code like that listed below.

param_summ2 = summarise_jags_cjs(cjs_post2)
param_summ2




param_summ2 %<>%
  left_join(tibble(site = colnames(jags_data$y)) %>%
              mutate(site = factor(site, levels = site),
                     site_num = as.integer(site))) %>%
  select(param_grp, site_num,
         site,
         param,
         everything())


surv_p2 = param_summ2 %>%
  filter(param_grp == 'survship') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Cumulative Survival')+
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("River", "Beach seine", "Purse seine", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

phi_p2 = param_summ2 %>%
  filter(param_grp == 'phi') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Survival From Previous Site')+
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("River", "Beach seine", "Purse seine", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

det_p2 = param_summ2 %>%
  filter(param_grp == 'p') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Detection Probability')+
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("River", "Beach seine", "Purse seine", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))


det_p2
phi_p2
surv_p2


ggarrange(det_p2, phi_p2, surv_p2,
          labels = c("A", "B", "C"),
          ncol = 3, nrow = 1)



postpack::diag_plots(cjs_post, "phi",
                     layout = "5x3")
postpack::diag_plots(cjs_post, "survship",
                     layout = "5x3")
postpack::diag_plots(cjs_post, "^p[",
                     layout = "5x3")
























######################################

## Plot to compare HATCHERY vs WILD

######################################



##Trying to make a combined figure with hatchery and wild survival
head(param_summ)

head(param_summ2)


param_summ$origin <- "hatchery"
param_summ2$origin <- "wild"

param_summ$site_num <- as.numeric(param_summ$site_num)
#param_summ['site_num'][param_summ['site_num'] == '3'] <- 5
#param_summ['site_num'][param_summ['site_num'] == '2'] <- 4
#param_summ['site_num'][param_summ['site_num'] == '1'] <- 3
head(param_summ)

param_summ2$site_num <- as.numeric(param_summ2$site_num)
#param_summ2['site_num'][param_summ2['site_num'] == '3'] <- 5
#param_summ2['site_num'][param_summ2['site_num'] == '2'] <- 4
#param_summ2['site_num'][param_summ2['site_num'] == '1'] <- 3
head(param_summ2)

param_summ3 <- rbind(param_summ,param_summ2)
head(param_summ3)

param_summ3$site_num<-as.factor(param_summ3$site_num)


surv_p3 = param_summ3 %>%
  filter(param_grp == 'survship') %>%
  ggplot(aes(x = site_num,
             y = mean,
             fill = origin,
             group = origin)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`,
                    colour = origin,
                    group = origin),
                width = 0.2) +
  geom_point(aes(colour = origin)) +
  geom_line(aes(colour = origin))+
  theme_classic() +
  labs(x = '',
       y = 'Cumulative Survival')+
  scale_x_discrete(breaks=c("1", "2", "3", "4", "5"),
                   labels=c("River", "Microtroll", "Adult return", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+
  theme(legend.position = c(.8,.95), legend.direction = "horizontal")+
  theme(legend.title=element_blank())

surv_p3 = param_summ3 %>%
  filter(param_grp == 'survship') %>%
  ggplot(aes(x = site_num,
             y = mean,
             fill = origin,
             group = origin)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`,
                    colour = origin,
                    group = origin),
                width = 0.2, size = 1) +  # Increase error bar thickness
  geom_point(aes(colour = origin), size = 3) +  # Increase point size
  geom_line(aes(colour = origin), size = 1.5) +  # Increase line thickness
  theme_classic() +
  labs(x = '',
       y = 'Cumulative Survival') +
  scale_x_discrete(breaks=c("1", "2", "3", "4", "5"),
                   labels=c("River", "Estuary", "Purse", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1, size = 15),  # Increase text size
        axis.text.y = element_text(size = 15),  # Increase text size
        axis.title = element_text(size = 17, face = "bold"),  # Increase text size
        legend.text = element_text(size = 15),  # Increase legend text size
        legend.title = element_text(size = 15),  # Increase legend title size
        legend.key.size = unit(2, "lines")) +  # Increase legend key size
  theme(legend.position = c(.5,-0.25), legend.direction = "horizontal",
        legend.title=element_blank())+
  theme(panel.grid.major = element_line(color = "lightgray"),
        panel.grid.minor = element_blank())+
  theme(axis.title.y = element_text(size = 17, margin = margin(r = 20)))+
  labs(title = "Cowichan River Chinook Salmon surival (2016)")+
  theme(title = element_text(size = 12, face = "bold"))

surv_p3







surv_p32 = param_summ3 %>%
  filter(param_grp == 'phi') %>%
  ggplot(aes(x = site_num,
             y = mean,
             fill = origin,
             group = origin)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`,
                    colour = origin,
                    group = origin),
                width = 0.2) +
  geom_point(aes(colour = origin)) +
  geom_line(aes(colour = origin))+
  theme_classic() +
  labs(x = '',
       y = 'Survival from previous site')+
  scale_x_discrete(breaks=c("1", "2", "3", "4", "5"),
                   labels=c("River", "Microtroll", "Adult return", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+
  theme(legend.position = c(.8,.95), legend.direction = "horizontal")+
  theme(legend.title=element_blank())

surv_p32



param_summ$site_num <- as.factor(param_summ$site_num)

surv_p4 = param_summ %>%
  filter(param_grp == 'survship') %>%
  ggplot(aes(x = site_num,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`,
                    colour = 'red'),
                width = 0.2) +
  geom_point(aes(colour = 'red')) +
  geom_line(aes(colour = 'red', group = 1))+
  theme_classic() +
  labs(x = '',
       y = 'Cumulative Survival')+
  scale_x_discrete(breaks=c("1", "2", "3", "4", "5"),
                   labels=c("Hatchery", "Downstream", "Estuary", "Microtroll", "Adult return")) +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))+
  theme(legend.position="none")

surv_p4



