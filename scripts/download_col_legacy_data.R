library(dplyr)
library(purrr)

#---- Load useful functions
source("./scripts/utils_download.R")

#---- Download and clean legacy data

# There is FIS in INS data from 2020-04-07 on
initial_legacy_date <- as.Date("2020-04-07")
final_legacy_date <- as.Date("2020-10-28")
legacy_dates <- seq.Date(
  initial_legacy_date, final_legacy_date,
  by = "week")

df_legacy <- concat_legacy_data(
  legacy_dates = legacy_dates
)
write.csv(
  df_legacy,
  "./data/col-legacy-individual.csv",
  row.names = FALSE
)
df_legacy <- read.csv("./data/col-legacy-individual.csv")

df_incidence_daily <- df_legacy %>%
  group_by(city, register, notification) %>%
  arrange(city, register, notification) %>%
  summarize(incidence = n()) %>%
  ungroup()

write.csv(
  df_incidence_daily,
  "./data/col-legacy-notification-daily-incidence.csv",
  row.names = FALSE
)

# df_incidence_daily <- df_legacy %>%
#   group_by(city, register, onset) %>%
#   arrange(city, register, onset) %>%
#   summarize(incidence = n()) %>%
#   ungroup()
#
# write.csv(
#   df_incidence_daily,
#   "./data/col-legacy-onset-daily-incidence.csv",
#   row.names = FALSE
# )

# df_notification_daily <- df_legacy %>%
#   group_by(city, register, notification) %>%
#   arrange(city, register, notification) %>%
#   summarize(incidence = n()) %>%
#   ungroup()

#### TEMPORAL

#####

# %>%
#   # group_by(city, register, onset) %>%
#   group_by(city, register, notification) %>%
#   summarize(incidence = n()) %>%
#   ungroup()
#
# write.csv(
#   df_legacy_daily,
#   # "./data/col-legacy-incidence-daily_fisconj.csv",
#   "./data/col-legacy-incidence-daily_fis.csv",
#   row.names = FALSE
# )


# TODO: LIMPIAR AGRUPACIÓN DE LOS DATOS
# TODO: REVISAR CONDICIONALES DE DESCARGA?
# df_legacy_med_daily <- concat_legacy_data(
#   legacy_dates = legacy_dates,
#   include_asympt = TRUE
# ) %>%
#   group_by(city, register, onset) %>%
#   summarize(incidence = n()) %>%
#   ungroup()

# df_legacy_col_daily <- rbind(df_legacy_bog_daily , df_legacy_med_daily)
#
# write.csv(
#   df_legacy_col_daily,
#   "./data/col-legacy-incidence-daily.csv",
#   row.names = FALSE
# )
#
# # Weekly incidence from legacy data
# df_weekly_incidence <- df_legacy_col_daily %>%
#   mutate(
#     onset_epiweek = grates::as_epiweek(.$onset)
#   ) %>%
#   group_by(city, register, onset_epiweek) %>%
#   summarize(incidence = n()) %>%
#   ungroup()
#
# df_weekly_incidence_ <- df_legacy_daily %>%
#   mutate(
#     onset_epiweek = grates::as_epiweek(.$onset)
#   ) %>%
#   group_by(city, register, onset_epiweek) %>%
#   summarize(incidence = n()) %>%
#   ungroup()
#
# write.csv(
#   df_weekly_incidence,
#   "./data/col-legacy-incidence-weekly.csv",
#   row.names = FALSE
# )
#
# # legacy_date <- "2020-06-23"
# # df_legacy_date <- read_and_clean_legacy_data(
# #   legacy_date,
# #   city_name = "Bogota",
# #   city_pattern = "^bog"
# # )
#
#
# ## Daily
# ggplot(
#   data = df_legacy_daily %>%
#     filter(onset <= as.Date("2020-10-31")),
#   aes(
#     x = onset,
#     y = incidence,
#     group = register,
#     color = as.factor(register)
#   )
# ) +
#   geom_point() +
#   geom_line() +
#   facet_wrap(~city, scales = "free") +
#   theme_classic()
#
# # Weekly
#
# ggplot(
#   data = df_weekly_incidence,
#   aes(
#     x = onset_epiweek, y = incidence,
#     group = register,
#     color = as.factor(register)
#   )
# ) +
#   geom_point() +
#   geom_line() +
#   facet_wrap(~city, scales = "free") +
#   theme_classic() +
#   theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
