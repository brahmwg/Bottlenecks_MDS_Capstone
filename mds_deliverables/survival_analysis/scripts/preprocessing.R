library(readr)
library(tidyr)
library(dplyr)
library(lubridate)

# Change location as needed
setwd("~/Library/Mobile\ Documents/com~apple~CloudDocs/Documents/Personal/jel000-notes/Capstone/Bottlenecks_MDS_Capstone/survival_analysis/")

data_to_read_from <- "data/raw/"
data_to_write_to <- "data/preprocessed/"

hatchery <- read_csv(paste0(data_to_read_from, "hatchery.csv"))

downstream_hatch <- read_csv(paste0(data_to_read_from, "downstream_hatch.csv"))
colnames(downstream_hatch)[colnames(downstream_hatch) == "avg_fork_length"] <- "fork_length_mm"

downstream_wild <- read_csv(paste0(data_to_read_from, "downstream_wild.csv"))
estuary <- read_csv(paste0(data_to_read_from, "estuary.csv"))
microtroll_hatch <- read_csv(paste0(data_to_read_from, "microtroll_hatch.csv"))
microtroll_wild <- read_csv(paste0(data_to_read_from, "microtroll_wild.csv"))
return <- read_csv(paste0(data_to_read_from, "return.csv"))

clean_raw_df <- function(df) {
  data_types <- list(
    tag_id = "double",
    date = "date",
    stage = "character",
    origin = "character",
    fork_length_mm = "numeric",
    action = "character",
    species = "character"
  )

  df <- df |> drop_na()

  for (col in names(data_types)) {
    if (data_types[[col]] == "double") {
      df <- df |> filter(!is.na(as.double(df[[col]])))
    } else if (data_types[[col]] == "date") {
      df <- df |> filter(!is.na(parse_date_time(df[[col]], orders = c("ymd", "mdy", "dmy"))))
    } else {
      df <- df |> filter(!is.na(df[[col]]))
    }
  }
  
  df <- df |> mutate(
    date = parse_date_time(date, orders = c("ymd", "mdy", "dmy")),
    fork_length_mm = as.numeric(fork_length_mm),
    origin = as.character(origin),
    tag_id = as.double(tag_id)
  )
  
  return(df)
}

data_list <- list(hatchery, downstream_hatch, downstream_wild, estuary,
                  microtroll_hatch, microtroll_wild, return)

data_list <- lapply(data_list, clean_raw_df)

estuary$origin <- ifelse(estuary$origin == "hatchery", "hatch", "wild")
return$origin <- ifelse(return$origin == "hatch_tag", "hatch", "wild")

combined <- bind_rows(data_list)

combined$action[combined$action == 'recap'] <- 'detect'

write.csv(combined, paste0(data_to_write_to, "preprocessed.csv"))

