library(readr)

setwd("~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents/Personal/jel000-notes/Capstone/Bottlenecks_MDS_Capstone/survival_analysis/")
items <- list.files()
print(items)

hatchery <- read_csv("raw_data2/hatchery.csv")
downstream_hatch <- read_csv("raw_data2/downstream_hatch.csv")
downstream_wild <- read_csv("raw_data2/downstream_wild.csv")
estuary <- read_csv("raw_data2/estuary.csv")
microtroll_hatch <- read_csv("raw_data2/microtroll_hatch.csv")
microtroll_wild <- read_csv("raw_data2/microtroll_wild.csv")
return <- read_csv("raw_data2/return.csv")

estuary$origin <- ifelse(estuary$origin == "hatchery", "hatch", "wild")
return$origin <- ifelse(return$origin == "hatch_tag", "hatch", "wild")

combined <- rbind(hatchery, downstream_hatch, downstream_wild, estuary,
                  microtroll_hatch, microtroll_wild, return)

combined$action[combined$action == 'recap'] <- 'detect'

write.csv(combined, "../survival_analysis/preprocessed_data/survival_analysis_1000.csv")
