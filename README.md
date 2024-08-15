# PETs Challenge: Epi-examples

## Challenge Description:

data.org, in partnership with a global financial services institution, Harvard OpenDP, and University of Javariana, has launched a Privacy Enhancing Technologies (PETs) for Public Health Challenge. Up to five winners will be awarded $50,000 each.

This pioneering competition invites academic innovators (Masters, PhDs, Postdocs, faculty, etc.) in differential privacy,  epidemiology, data science, and machine learning, etc. to create privacy solutions that will help unlock sensitive data for public health advancements and drive social impact.  

You can also find more information about the challenge, timing, and funding awards, etc. by visiting Privacy-Enhancing Technologies (PETs) for Public Health Challenge - https://data.org/initiatives/pets-challenge/

## Notebooks

In this repository you will find examples for some of the 
[Epidemiological decision-making policy scenario](https://data.org/initiatives/pets-challenge/about/) of the challenge 
using open source databases available online for the 4 selected locations.The notebooks include examples on:

- Effective reproduction number estimations using {EpiEstim} ([A. Cori, et al. 2013](https://academic.oup.com/aje/article-abstract/178/9/1505/89262)) for Bogotá D.C., 
Medellín and Brasília
- Nowcasting of COVID-19 cases for Bogotá D.C. using [{EpiNow2}](https://epiforecasts.io/EpiNow2/dev/index.html)
- Forecasting of deaths in Bogotá D.C. using {sktime}

## Open COVID-19 Datasets:

### Colombia:

The sources for both Bogotá D.C. and Medellín cities are alocated by the 
[National Institute of Health](https://www.ins.gov.co/Noticias/Paginas/coronavirus-casos.aspx). There you will be able to find the 
[updated cases dataset](https://www.datos.gov.co/Salud-y-Protecci-n-Social/Casos-positivos-de-COVID-19-en-Colombia-/gt2j-8ykr/data) 
and a [historical (legacy) list of datasets](https://www.ins.gov.co/Paginas/Boletines-casos-COVID-19-Colombia.aspx) 
corresponding to snapshots of the data available in real time.

In the following table you can see a summary of 
some variables of interests in the updated dataset:

|Name                     |Description                                            |Type     |
|-------------------------|-------------------------------------------------------|---------|
|fecha reporte web        |Date of publication in the website                     |POSIXct  |
|fecha de notificación    |Notification date in the SIVIGILA platform             |POSIXct  |
|Código DIVIPOLA municipio|Municipality code (`11001` for Bogotá, `5001` for Medellín)|Integer  |
|Nombre municipio         |Municipality name                                      |Character|
|Edad                     |Age                                                    |Integer  |
|Unidad de medida de edad |Age measurement unit (1-years, 2-months, 3-days)       |Integer  |
|Sexo                     |Sex                                                    |Character|
|Estado                   |Patient state (used to filter deceased cases)          |Character|
|Recuperado               |Recuperado (Recovered), Fallecido (Deceased),N/A (Deceased by other causes than COVID)                                                                            |Character|
|Fecha de inicio de síntomas|Date of onset                          |POSIXct  |
|Fecha de muerte          |Date of death                                          |POSIXct  |
|Fecha de diagnóstico     |Laboratory confirmation date                           |POSIXct  |
|Fecha de recuperación    |Date of recovery                                       |POSIXct  |

**This data ranges from March 2020 up to January 2024**. You can find a pipeline to read and group this dataset in the script 
`download_covid19_data.R`. 

The available legacy data consists of individual tables for each date. During 
early stages of the pandemic, public health agencies had not agreed yet on what 
structure should the data have, which is why not all the tables have the same 
structure. Similar variables to those in the table above may be available on 
each snapshot of the data under different names and with different data types. 
The script `download_col_legacy_data.R` reads the legacy data directly from the 
[source](https://www.ins.gov.co/Paginas/Boletines-casos-COVID-19-Colombia.aspx), 
looks for the notification and onset dates, and concatanates the snapshots in 
a single data frame labelling each snapshot by its register date. This is done 
for one snapshot per week from April to October 2020. Then, the incidences by 
notification and onset are computed grouping the data. This data is used to 
correct right truncation bias due to notfication delay in the 
[Nowcasting notebook](https://github.com/TRACE-LAC/pet-epi-notebooks/blob/main/notebooks/Nowcasting-EpiNow2.Rmd).

#### Coarse-grained spatial information for Bogotá D.C.

Additional spatial information at the individual level can be found in the [confirmed cases for Bogotá city published by datosabiertos.bogota.gov.co](https://datosabiertos.bogota.gov.co/dataset/numero-de-casos-confirmados-por-el-laboratorio-de-covid-19-bogota-d-c), where the column `Localidad` refers to the residence area of each case (NOTE: As of 14/08/2024, does not have `Localidad` as before); each residence area can correspond to several postcodes according to the following table (extracted from [here](https://data.opendatasoft.com/explore/dataset/geonames-postal-code@public/export/a)):

| Localidad          | Códigos Postales |
| ------------------ | ---------------- |
| Usaquén            | 110111-110151    |
| Chapinero          | 110211-110231    |
| Santa Fe           | 110311-110321    |
| San Cristóbal      | 110411-110441    |
| Usme               | 110511-110571    |
| Tunjuelito         | 110611-110621    |
| Bosa               | 110711-110741    |
| Kennedy            | 110811-110881    |
| Fontibón           | 110911-110931    |
| Engativá           | 111011-111071    |
| Suba               | 111111-111176    |
| Barrios Unidos     | 111211-111221    |
| Teusaquillo        | 111311-111321    |
| Los Mártires       | 111411           |
| Antonio Nariño     | 111511           |
| Puente Aranda      | 111611-111631    |
| La Candelaria      | 111711           |
| Rafael Uribe Uribe | 111811-111841    |
| Ciudad Bolívar     | 111911-111981    |
| Sumapaz            | 112011-112041    |

Otherwise, the dataset is fairly similar to that from the INS referred above. 
Which you can get by filtering:

```r
zipcodes_pets <- df_zipcodes %>%
  filter((`country code` == "CO" & `admin name1` == "Antioquia" & `admin name2` == "Medellín"))
```

Similarly for all the locations:
```r
zipcodes_pets <- df_zipcodes %>%
  filter(
      (`country code` == "BR" & `admin name1` == "Distrito Federal") |
      (`country code` == "CL" & `admin name1` == "Región Metropolitana") |
      (`country code` == "CO" & `admin name1` == "Bogota, D.C.") |
      (`country code` == "CO" & `admin name1` == "Antioquia" & `admin name2` == "Medellín")
  )
```
### Brasilia

A compelling compilation of COVID-19 related data for Brazil is available in the
[covid19br GitHub repository](https://github.com/wcota/covid19br) by Wesley Cota.
The data set `cases-brazil-states.csv` contains the following relevant variables
(among others):

| name                            | description                                             | Type      |
|---------------------------------|---------------------------------------------------------|-----------|
| epi_week                        | Epidemiological week                                    | Integer   | 
| date                            | Notification date                                       | Date      |
| country                         | Name of the country (always `"Brazil"`)                 | Character |
| state                           | Name of the federative unit (`"DF"` for Brazilia)       | Character |
| city                            | Name of the municipality                                | Character |
| newDeaths                       | Number of reported new deaths                           | Integer   |
| deaths                          | Total number of deaths                                  | Integer   |
| newCases                        | Number of reported new cases                            | Integer   |
| totalCases                      | Total number of cases                                   | Integer   |

**This data ranges from March 2020 up to March 2023**. A complete description of the dataset can be found in the 
[English version](https://github.com/wcota/covid19br/blob/master/README.en.md) 
of the README in the source repository.

Although real-time snapshots of the data are not directly available, tt may be 
possible to extract them from the git history of the repository by searching for 
old versions of the `cases-brazil-states.csv`. Moreover, a complete example 
nowcasting for Brazil can be found in the 
[Observatório Covid-19 BR](https://github.com/covid19br) project, where the 
[Nowcaster package](https://github.com/covid19br/nowcaster) is employed.

### Santiago de Chile

Individual level data about deaths caused by COVID-19 in Santiago de Chile can 
be found in 
[Centralized open repository of state](https://datos.gob.cl/dataset/8982a05a-91f7-422d-97bc-3eee08fde784),
which contains a cumulative register of deceases. The following table is a 
summarized data dictionary for this dataset:

| name                      | description                                                           | Type      |
|---------------------------|-----------------------------------------------------------------------|-----------|
| FECHA_DEF                 | Date of death                                                         | Date      |
| SEXO_NOMBRE               | Biological sex                                                        | Character |
| EDAD_TIPO                 | Age measurement unit (1-years, 2-months)                              | Integer   |
| EDAD_CANT                 | Age                                                                   | Character |
| CODIGO_COMUNA             | Code of the residence commune of the diseased                         | Integer   |
| COMUNA                    | Residence commune of the diseased (`"Santiago"` for Santiago de Chile)| Character |
| GLOSA_SUBCATEGORIA_DIAG1  | Cause of death                                                        | Character |
| CODIGO_CATEGORIA_DIAG1    | Code of the cause of death (`"U071"` for identified covid19 cases)     | Integer   |

**This data ranges from April 2020 up to February 2024**. A complete data dictionary can be downloaded from the source. Similarly as for 
the INS' data from Colombia, in the `download_covid19_data.R` script you can find
a simple pipeline to clean and group this dataset to obtain the daily incidence 
of deaths.

