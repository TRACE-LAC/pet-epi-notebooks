library(dplyr)
library(purrr)

#---- Load useful functions
source("./scripts/read_and_clean_legacy_data.R")

#---- Download and clean legacy data

# There is FIS in INS data from 2020-04-07 on
initial_legacy_date <- as.Date("2020-04-07")
# final_legacy_date <- as.Date("2020-10-28")
final_legacy_date <- as.Date("2020-08-25")
legacy_dates <- seq.Date(
  initial_legacy_date, final_legacy_date,
  by = "week"
  )

df_legacy <- data.frame()
for(date in as.character(legacy_dates)) {
  print(date)
  df_legacy_date <- read_and_clean_legacy_data(date)
  df_legacy <- rbind(df_legacy, df_legacy_date)
}
rm(df_legacy_date)

# write.csv(
#   df_legacy,
#   "./data/covid19_col_legacy_individual.csv",
#   row.names = FALSE
# )
# df_legacy <- read.csv("./data/covid19_col_legacy_individual.csv")

df_notification_incidence_daily <- df_legacy %>%
  group_by(city, register, notification) %>%
  arrange(city, register, notification) %>%
  summarize(incidence = n()) %>%
  ungroup()

write.csv(
  df_notification_incidence_daily,
  "./data/covid19_col_legacy_notification_daily_incidence.csv",
  row.names = FALSE
)

df_onset_incidence_daily <- df_legacy %>%
  group_by(city, register, onset) %>%
  arrange(city, register, onset) %>%
  summarize(incidence = n()) %>%
  ungroup()

write.csv(
  df_onset_incidence_daily,
  "./data/covid19_col_legacy_onset_daily_incidence.csv",
  row.names = FALSE
)

rm(df_legacy)

