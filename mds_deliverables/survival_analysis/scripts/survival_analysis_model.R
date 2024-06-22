library(devtools)
library(postpack)
library(coda)
library(remotes)
library(rjags)
library(telemetyr)
library(dplyr)
library(ggplot2)
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
library(knitr)
library(MCMCvis)
library(purrr)

setwd("~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents/Personal/jel000-notes/Capstone/Bottlenecks_MDS_Capstone/survival_analysis/")
survdata <- read_csv("data/preprocessed/preprocessed.csv")

survdata <- survdata[,2:8]
survdata <- survdata[survdata$species %in% c("co", "ck"), ]

survdata <- survdata[sample(nrow(survdata), 1000, replace = FALSE), ]

survdata$stage<-as.factor(survdata$stage)
survdata$origin<-as.factor(survdata$origin)
survdata$action<-as.factor(survdata$action)
survdata$juliandate <- yday(survdata$date)  
survdata$juliandate<-as.factor(survdata$juliandate)
survdata$species<-as.factor(survdata$species)

hatchsurv <- survdata

hatchsurv$action <- droplevels(hatchsurv$action)

hatchtag <- hatchsurv[which(substr(hatchsurv$action,1,3)=="tag"),]

hatchdown <- hatchsurv[which(substr(hatchsurv$stage,1,10)=="downstream"),] 

hatchestuary <- hatchsurv[ which( hatchsurv$stage == "estuary" & 
                                    hatchsurv$action == "detect") , ]

hatchmicro <- hatchsurv[which(substr(hatchsurv$stage,1,5)=="micro" &
                                hatchsurv$action == "detect" ),]

hatchreturn <- hatchsurv[which(substr(hatchsurv$stage,1,6)=="return"),]

df_list <- list(hatchtag, hatchdown, hatchestuary, hatchmicro, hatchreturn)

hatchtotal <- df_list |> reduce(full_join, by='tag_id')

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

hatchtotal$origin.x <- with(hatchtotal, ifelse(origin.x == "hatch",
                                               "1", "0"))

hatchtotal$t1 <- as.factor(hatchtotal$t1)
hatchtotal$t2 <- as.factor(hatchtotal$t2)
hatchtotal$t3 <- as.factor(hatchtotal$t3)
hatchtotal$t4 <- as.factor(hatchtotal$t4)
hatchtotal$t5 <- as.factor(hatchtotal$t5)
hatchtotal$origin.x <- as.factor(hatchtotal$origin.x)

hatchtotal$ch <- paste(hatchtotal$t1, hatchtotal$t2, hatchtotal$t3, hatchtotal$t4, hatchtotal$t5, sep = "")

names(hatchtotal)[names(hatchtotal) == "ch"] <- "cap_hist"
hatchtotal$duty_cycle <- "batch_1"

hatchtotal$tag_id<-as.numeric(as.character(hatchtotal$tag_id))
hatchtotal$t1<-as.numeric(as.character(hatchtotal$t1))
hatchtotal$t2<-as.numeric(as.character(hatchtotal$t2))
hatchtotal$t3<-as.numeric(as.character(hatchtotal$t3))
hatchtotal$t4<-as.numeric(as.character(hatchtotal$t4))
hatchtotal$t5<-as.numeric(as.character(hatchtotal$t5))

hatchtotal$cap_hist<-as.numeric(as.character(hatchtotal$cap_hist))

hatchsimple <- hatchtotal[c(1, 42, 4, 37:41)]
names(hatchsimple)[names(hatchsimple) == "origin.x"] <- "origin"

hatchsimple2 <- hatchsimple[!duplicated(hatchsimple$tag_id), ]

hatchsimple_clean <- hatchsimple2[!is.na(hatchsimple2$origin), ]
hatchsimple_clean <- hatchsimple_clean |>
  mutate(origin = as.numeric(origin),
         origin = origin - 1)

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
    
    survship[1] <- 1 # the tagging stage (stage 1)
    for (j in 2:J) { # the rest of the stages (stages 2-5)
      survship[j] <- survship[j-1] * phi[j]
    }
  }
  
  postpack::write_model(jags_model, file_path)
}

write_bayes_cjs(file_path = 'CJS_model_edited.txt')

jags_data = prep_jags_cjs(
  cap_hist_wide = hatchsimple_clean,
  tag_meta = hatchtotal,
  drop_col_nm = "duty_cycle",
  drop_values = c("batch_2", "batch_3")
)


cjs_post = run_jags_cjs(file_path = 'CJS_model_edited.txt',
                        jags_data = jags_data,
                        n_chains = 4,
                        n_adapt = 1000,
                        n_burnin = 2500,
                        n_iter = 2500,
                        n_thin = 5,
                        params_to_save = c("phi", "p", "survship"),
                        rng_seed = 4)

param_summ = summarise_jags_cjs(cjs_post)
param_summ = param_summ %<>%
  left_join(tibble(site = colnames(jags_data$y)) %>%
              mutate(site = factor(site, levels = site),
                     site_num = as.integer(site))) %>%
  select(param_grp, site_num,
         site,
         param,
         everything())

write_csv(param_summ, "data/param_summ.csv")

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

ggsave("plots/surv_p.png", plot = surv_p, width = 8, height = 6, dpi = 300)

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

ggsave("plots/phi_p.png", plot = phi_p, width = 8, height = 6, dpi = 300)

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

ggsave("plots/p_plot.png", plot = det_p, width = 8, height = 6, dpi = 300)

ggarrange(det_p, phi_p, surv_p,
          labels = c("A", "B", "C"),
          ncol = 3, nrow = 1)
postpack::diag_plots(cjs_post, "phi",
                     layout = "4x2")
postpack::diag_plots(cjs_post, "survship",
                     layout = "4x2")
postpack::diag_plots(cjs_post, "^p[",
                     layout = "4x2")

