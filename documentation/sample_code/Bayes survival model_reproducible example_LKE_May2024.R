
#####################################################
#####################################################

## BAYESIAN CJS MODEL FOR BOTTLENECKS PROJECT DATA ##

#####################################################
#####################################################

#Script developed and written by L. Elmer



## Hi students! This is a simplified script that should be a good intro to the model for you to work through
## Run this script with the .txt file 'data6' - this is simulated data that I created to represent the actual bottlenecks data
## It is not the cleanest of scripts, but hopefully everything makes enough sense - feel free to reach out if you need further clarification or any code is not working




## Load libraries:

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


#########First prep the simulated data


## Load dataset

getwd()

survdata <- read.delim("/Users/lauraelmer/Library/CloudStorage/Dropbox-BCSRIFBottlenecks/Laura Elmer/PSF bottlenecks/data6.txt", sep = " ")
head(survdata)


survdata$stage<-as.factor(survdata$stage)
survdata$origin<-as.factor(survdata$origin)
survdata$action<-as.factor(survdata$action)
survdata$juliandate <- yday(survdata$date)  
survdata$juliandate<-as.factor(survdata$juliandate)




## Create two separate datasets for wild vs hatchery fish


wildsurv <- survdata[which(substr(survdata$origin,1,4)=="wild"),] 
hatchsurv <- survdata[which(substr(survdata$origin,1,5)=="hatch"),] 







########################################################


## let's just work with HATCHERY FISH to start with


########################################################



#change 'recap' to 'detect' for consistency
hatchsurv$action[hatchsurv$action=="recap"] <- "detect"
hatchsurv$action <- droplevels(hatchsurv$action)
hatchsurv$action


hatchtag <- hatchsurv[which(substr(hatchsurv$action,1,3)=="tag"),] 
hatchdown <- hatchsurv[which(substr(hatchsurv$stage,1,10)=="downstream"),] 
hatchestuary <- hatchsurv[ which( hatchsurv$stage == "estuary" & hatchsurv$action == "detect") , ]
hatchmicro <- hatchsurv[which(substr(hatchsurv$stage,1,5)=="micro" & hatchsurv$action == "detect" ),]
hatchreturn <- hatchsurv[which(substr(hatchsurv$stage,1,6)=="return"),]


df_list <- list(hatchtag, hatchdown, hatchestuary, hatchmicro, hatchreturn)
hatchtotal <- df_list %>% reduce(full_join, by='tag')


hatchtotal$t1 <- with(hatchtotal, ifelse(stage.x %in% c("facility") & 
                                           action.x == "tag", 
                                         "1", "0"))

hatchtotal$t2 <- with(hatchtotal, ifelse(stage.y %in% c("downstream") & 
                                           action.y == "detect", 
                                         "1", "0"))

hatchtotal$t3 <- with(hatchtotal, ifelse(stage.x %in% c("estuary") |
                                           stage.x.x %in% c("estuary"),
                                         "1", "0"))

hatchtotal$t4 <- with(hatchtotal, ifelse(stage.x %in% c("micro") |
                                           stage.y.y %in% c("micro"),
                                         "1", "0"))

hatchtotal$t5 <- with(hatchtotal, ifelse(stage %in% c("return"),
                                         "1", "0"))

#hatchtotal$t6 <- hatchtotal$t5

hatchtotal$t1 <- as.factor(hatchtotal$t1)
hatchtotal$t2 <- as.factor(hatchtotal$t2)
hatchtotal$t3 <- as.factor(hatchtotal$t3)
hatchtotal$t4 <- as.factor(hatchtotal$t4)
hatchtotal$t5 <- as.factor(hatchtotal$t5)
#hatchtotal$t6 <- as.factor(hatchtotal$t6)

hatchtotal$ch <- paste(hatchtotal$t1, hatchtotal$t2, hatchtotal$t3, hatchtotal$t4, hatchtotal$t5, sep = "")
#hatchtotal$ch <- paste(hatchtotal$t1, hatchtotal$t2, hatchtotal$t3, hatchtotal$t4, hatchtotal$t5, hatchtotal$t6, sep = "")




head(hatchtotal)



#rename some columns
names(hatchtotal)[names(hatchtotal) == "tag"] <- "tag_id"
names(hatchtotal)[names(hatchtotal) == "ch"] <- "cap_hist"
hatchtotal$duty_cycle <- "batch_1"
head(hatchtotal)

hatchtotal$tag_id<-as.numeric(as.character(hatchtotal$tag_id))
hatchtotal$t1<-as.numeric(as.character(hatchtotal$t1))
hatchtotal$t2<-as.numeric(as.character(hatchtotal$t2))
hatchtotal$t3<-as.numeric(as.character(hatchtotal$t3))
hatchtotal$t4<-as.numeric(as.character(hatchtotal$t4))
hatchtotal$t5<-as.numeric(as.character(hatchtotal$t5))
#hatchtotal$t6<-as.numeric(as.character(hatchtotal$t6))

head(hatchtotal)


#Run the below line of code to randomly subset the simulated dataset - this mean the model runs quicker below
#hatchtotal <- hatchtotal[sample(nrow(hatchtotal), 200), ]

#Make a simpler dataset with just the columns we want
hatchsimple <- hatchtotal[c(1, 37, 32:36)]
#hatchsimple <- hatchtotal[c(2, 42, 37:41)]
head(hatchsimple)
head(hatchtotal)

#hatchtotal2 <- hatchtotal


hatchsimple2 <- hatchsimple[!duplicated(hatchsimple$tag_id), ]  




hatchsimple %>%
  group_by(t1, t2, t3, t4, t5, cap_hist) %>%
  dplyr::summarise(freq = n()) %>%
  kable()


tagsum <- hatchsimple2 %>%
  group_by(t1, t2, t3, t4, t5, cap_hist) %>%
  dplyr::summarise(freq = n()) 
tagsum




##


#Write the JAGS model. 

#We want to estimate:
    # 1 - detection (recapture) probability at each site
    # 2 - survival probabilities between each site, 
    # 3 - cumulative survival over time ('survival curve')
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
    
    
    # Experimenting with more informative priors:
    
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
    
    
    
    
    # LIKELIHOOD 
    for (i in 1:N) {
      # j = f[i] is the release occasion - known alive; i.e., the tagging event
      for (j in (f[i] + 1):J) {
        
        # survival process: 
        z[i,j] ~ dbern(phi[j] * z[i,j-1]) # fish i in period j is a bernoulli trial
        
        # detection process: 
        y[i,j] ~ dbern(p[j] * z[i,j]) # another bernoulli trial
      }
    }
    
    
    
    # DERIVED QUANTITIES
    # survivorship is probability of surviving from tagging to a detection occasion
    survship[1] <- 1 # the tagging stage (stage 1)
    for (j in 2:J) { # the rest of the stages (stages 2-5)
      survship[j] <- survship[j-1] * phi[j]
    }
  }
  
  postpack::write_model(jags_model, file_path)
}


write_bayes_cjs(file_path = 'CJS_model2.txt')


#Next, we must prepare our data for this model, which is done using the function prep_jags_cjs()

jags_data = prep_jags_cjs(
  cap_hist_wide = hatchsimple2,
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


# The next step is to run the MCMC algorithm. For this we use the rjags package to connect R to JAGS and extract samples from the posteriors of each parameter.
#The below line of code is what might take some time. For my computer, this dataset, and the below defined model inputs, it takes ~ 10-15 mins

cjs_post = run_jags_cjs(file_path = 'CJS_model2.txt',
                        jags_data = jags_data,
                        n_chains = 4,
                        n_adapt = 1000,
                        n_burnin = 2500,
                        n_iter = 2500,
                        n_thin = 5,
                        params_to_save = c("phi", "p", "survship"),
                        rng_seed = 4)




# Summarise the posterior samples 

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
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("Hatchery", "Downstream", "Estuary", "Microtroll", "Adult return")) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Cumulative Survival')+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

surv_p



phi_p = param_summ %>%
  filter(param_grp == 'phi') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                   labels=c("Hatchery", "Downstream", "Estuary", "Microtroll", "Adult return")) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Survival From Previous Site')+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

phi_p


det_p = param_summ %>%
  filter(param_grp == 'p') %>%
  ggplot(aes(x = site,
             y = mean)) +
  geom_errorbar(aes(ymin = `2.5%`,
                    ymax = `97.5%`),
                width = 0) +
  scale_x_discrete(breaks=c("t1","t2","t3", "t4", "t5"),
                     labels=c("Hatchery", "Downstream", "Estuary", "Microtroll", "Adult return")) +
  geom_point() +
  theme_classic() +
  labs(x = '',
       y = 'Detection Probability')+
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))

det_p



ggarrange(det_p, phi_p, surv_p,
          labels = c("A", "B", "C"),
          ncol = 3, nrow = 1)


postpack::diag_plots(cjs_post, "phi",
                     layout = "4x2")
postpack::diag_plots(cjs_post, "survship",
                     layout = "4x2")
postpack::diag_plots(cjs_post, "^p[",
                     layout = "4x2")








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


