library(dplyr)
library(stringi)
library(tidyr)


#---- Useful functions
read_and_clean_legacy_data <- function(
    legacy_date,
    filter_city = TRUE
) {
  # browser()
  # Read legacy data from the web
  url <- paste0(
    "https://www.ins.gov.co/BoletinesCasosCOVID19Colombia/",
    legacy_date,
    ".xlsx"
  )
  df <- openxlsx::read.xlsx(url)

  # Convert names to lower case and removes accents
  colnames(df) <- tolower(stri_trans_general(colnames(df), "Latin-ASCII"))
  # browser()
  # Select dates of interest and set column names
  if("ciudad" %in% colnames(df)) {
    df_selection <- df %>%
      select(ciudad,
             contains("fecha") & contains("not"),
             contains("inicio"))
  }

  if("ciudad_municipio" %in% colnames(df)) {
    if(typeof(df$ciudad_municipio) == "character"){
      df_selection <- df %>%
        select(ciudad_municipio,
               contains("fecha") & contains("not"),
               contains("inicio"))
    }
    if(typeof(df$ciudad_municipio) == "integer" &
       "municipio" %in% colnames(df)){
      df_selection <- df %>%
        select(municipio,
               contains("fecha") & contains("not"),
               contains("inicio"))
    }
  }

  if("nombre_mun" %in% colnames(df)) {
    df_selection <- df %>%
      select(nombre_mun,
             contains("fecha") & contains("not"),
             contains("inicio"))
  }
  if("ciudad.municipio" %in% colnames(df)) {
    if(typeof(df$ciudad.municipio) == "character"){
      df_selection <- df %>%
        select(ciudad.municipio,
               contains("fecha") & contains("not"),
               contains("inicio"))
    }
  }

  if("municipio" %in% colnames(df)) {
    if(typeof(df$municipio) == "character") {
      df_selection <- df %>%
        select(municipio,
               contains("fecha") & contains("not"),
               contains("inicio"))
    }
  }

  colnames(df_selection) <- c("city", "notification", "onset")

  # Clean dates format
  if(typeof(df_selection$notification) == "character") {
    df_selection$notification <- as.numeric(df_selection$notification)
  }
  if(typeof(df_selection$onset) == "character") {
    df_selection$onset <- as.numeric(df_selection$onset)
  }
  if(any(df_selection[!is.na(df_selection$onset), ]$onset < 43000)
  ) {
    warning("Numeric dates not in the right range")
  }

  df_selection <- df_selection %>%
    # Filter data from Bogota and Medellin only
    mutate(
      city = case_when(
        stringr::str_detect(tolower(city), pattern = "^bog") ~ "Bogota",
        stringr::str_detect(tolower(city), pattern = "^med") ~ "Medellin",
        TRUE ~ NA
      )
    ) %>%
    drop_na(city) %>%
    # Convert dates to standard dates format
    mutate(
      onset = as.Date(onset, origin = "1899-12-30"),
      notification = as.Date(notification, origin = "1899-12-30"),
      register = legacy_date
    ) %>%
    filter(onset >= as.Date("2020-03-01")) %>%
    relocate(register, .after = city)

  return(df_selection)
}

concat_legacy_data <- function(
    legacy_dates
) {
  df_legacy <- data.frame()
  for(n_date in 1:length(legacy_dates)) {
    print(legacy_dates[n_date])
    df_legacy_date <- read_and_clean_legacy_data(
      legacy_dates[n_date]
    )
    df_legacy <- rbind(df_legacy, df_legacy_date)
  }
  return(df_legacy)
}
