library(readr)

hatchery <- read_csv("raw_data/hatchery.csv")
downstream_hatch <- read_csv("raw_data/downstream_hatch.csv")
downstream_wild <- read_csv("raw_data/downstream_wild.csv")
estuary <- read_csv("raw_data/estuary.csv")
microtroll_hatch <- read_csv("raw_data/microtroll_hatch.csv")
microtroll_wild <- read_csv("raw_data/microtroll_wild.csv")
return <- read_csv("raw_data/return.csv")

return$origin <- ifelse(return$origin == "hatch_tag", "hatch", "wild")

combined <- rbind(hatchery, downstream_hatch, downstream_wild, estuary,
                  microtroll_hatch, microtroll_wild, return)

combined$action[combined$action == 'recap'] <- 'detect'

write.csv(combined, "../survival_analysis/preprocessed_data/survival_analysis.csv")
