library(dplyr)
library(data.table)

# Initial and final dates
initial_date <- as.Date("2020-01-01")
final_date <- as.Date("2022-12-31")

# Colombia
url <- "https://www.datos.gov.co/api/views/gt2j-8ykr/rows.csv?accessType=DOWNLOAD"

df_covid19_col_full <- fread(url) %>%
  filter(
    `Código DIVIPOLA municipio` %in% c(5001, 11001)
  ) %>%
  rename(
    onset = "Fecha de notificación",
    death = "Fecha de muerte",
    city = "Código DIVIPOLA municipio"
  ) %>%
  mutate(
    country = "Colombia",
    city = case_when(
      city == 5001 ~ "Medellin",
      city == 11001 ~ "Bogota",
      TRUE ~ "NA"
    )
  ) %>%
  select(onset, death, country, city, Estado)

df_covid19_col <- full_join(
  df_covid19_col_full %>%
    count(onset, country, city, name = "cases") %>%
    rename(date = onset),
  df_covid19_col_full %>%
    filter(Estado == "Fallecido") %>%
    count(death, country, city, name = "deaths") %>%
    rename(date = death),
  by = c("date", "country", "city")
  ) %>%
  mutate(
    date = as.Date(date)
  )

rm(df_covid19_col_full)

# Brasil
url <- "https://raw.githubusercontent.com/wcota/covid19br/master/cases-brazil-states.csv"

df_covid19_br <- fread(url) %>%
  select(date, country, state, newCases, newDeaths) %>%
  filter(state == "DF") %>%
  rename(
    city = state,
    cases = newCases,
    deaths = newDeaths
  ) %>%
  mutate(
    date = as.Date(date),
    city = "Brasilia"
  )

# Chile (only deaths)

url <- "https://datos.gob.cl/dataset/8982a05a-91f7-422d-97bc-3eee08fde784/resource/8e5539b7-10b2-409b-ae5a-36dae4faf817/download/defunciones_covid19_2020_2024.csv"

df_covid19_ch <- fread(url, sep = ";") %>%
  filter(COMUNA == "Santiago") %>%
  rename(
    date = FECHA_DEF,
    city = COMUNA
  ) %>%
  mutate(
    date = as.Date(date)
  ) %>%
  count(date, city, name = "deaths") %>%
  right_join(
    all_dates <- data.frame(
      date = seq.Date(
        min(.$date, na.rm = TRUE),
        max(.$date, na.rm = TRUE),
        by = "day"
      )
    )
  ) %>%
  mutate(
    country = "Chile",
    city = "Santiago",
    cases = NA
  ) %>%
  relocate(
    cases, .before = deaths
  ) %>%
  relocate(
    country, .before = city
  )


# Concatenate data
df_covid19_daily <- rbind(df_covid19_col, df_covid19_br, df_covid19_ch) %>%
  mutate(
    epi_week = paste0(
      as.numeric(format(date, format = "%Y")),
      "-",
      lubridate::epiweek(date)
    ),
    # year = as.numeric(format(date, format = "%Y")),
    # epi_week = lubridate::epiweek(date),
    cases = if_else(is.na(cases), 0, as.numeric(cases)),
    deaths = if_else(is.na(deaths), 0, as.numeric(deaths)),
  ) %>%
  arrange(date) %>%
  relocate(epi_week, .after = date) %>%
  group_by(country, city) %>%
  mutate(
    cum_cases = cumsum(cases),
    cum_deaths = cumsum(deaths)
  ) %>%
  ungroup() %>%
  filter(date >= initial_date & date <= final_date)

write.csv(df_covid19_daily, "./data/covid19_cases_deaths_daily.csv", row.names = FALSE)

df_covid19_weekly <- df_covid19_daily %>%
  select(-date) %>%
  group_by(country, city, epi_week) %>%
  arrange(country, city, epi_week) %>%
  summarise(across(c(cases, deaths), sum)) %>%
  mutate(
    cum_cases = cumsum(cases),
    cum_deaths = cumsum(deaths)
  ) %>%
  ungroup()

write.csv(df_covid19_weekly, "./data/covid19_cases_deaths_weekly.csv", row.names = FALSE)

rm(df_covid19_col, df_covid19_br, df_covid19_ch, url)
