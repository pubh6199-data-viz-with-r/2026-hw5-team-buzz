# optional, save your exploration code here
sfdata <- read_csv("data/SF_NPL_data.csv")%>%
    #filter by NPL Status and Decision Document
   filter(NPL_Status %in% "Currently on the Final NPL")%>%
   filter(Decision_Document_Type %in% "Record of Decision") %>%
    #remove duplicate media types and site names while keeping the original df
    distinct(Site_Name, Media, .keep_all = TRUE)%>%
    #make a new column with contaminated media type by site
    group_by(Site_Name)%>%
    mutate(Media_Types = toString(Media))%>%
   #remove contaminant name and original media column with only one type
    select(-Media, -Contaminant)%>%
   #remove any duplicate sites by their lat and long coordinates while keeping df
    distinct(Latitude, Longitude, .keep_all = TRUE)%>%
   #remove rows with missing county name 
    drop_na(County)%>%
  #Make a new column that categorizes the media type of interest numerically
    mutate(Media_int = case_when(
      str_detect(Media_Types,"Building/Structure") &
        str_detect(Media_Types, "Debris") ~ 3,
        str_detect(Media_Types, "Buildings/Structures") ~ 1,
        str_detect(Media_Types, "Debris") ~ 2,
      TRUE ~ 0
      )
    )





#Importing fire data

#installing package to extract CSV sheets from an xlsx file
library("tidyverse")
install.packages("readxl")
library(readxl)

#reading excel file target sheet to a CSV file 
fire_counties <- read_excel("data/fire_dataset.xlsx", sheet = "Counties")

#checking file 
view(fire_counties)


#loading packages necessary for obtaining county shapefiles 
library(dplyr)
install.packages("tidycensus")
library(tidycensus)
library(stringr)

#mutating fire county field to be all upper case with the "COUNTY at the end dropped, to match Superfund and county shapefile fields
fire_counties <- fire_counties %>%
  mutate(NAME = str_remove(NAME, ",.*")) %>%
  mutate(NAME = toupper(NAME)) %>%
  mutate(NAME = str_remove(NAME, " COUNTY")) %>%
  mutate(COUNTYFP = as.character(COUNTYFP))

#Checking revisions were done correctly
view(fire_counties)
class(fire_counties$COUNTYFP)


#Importing county shapefiles
#Loading necessary packages for mapping
install.packages("tmap") 
install.packages("tigris")
install.packages("leaflet")
library(tidyverse)
library(tmap)
library(sf)
library(tigris)
library(leaflet)

options(tigris_use_cache = TRUE)

#assigning counties to a dataframe
counties <- tigris::counties(cb = TRUE, year = 2025) 
#changing county names to all upper case and removing VI
counties <- counties %>%
  filter(!STATEFP %in% "78") %>%
  mutate(NAME = toupper(NAME))
 

#Checking rename was correct

view(counties)

#Left join of fire and county shapefiles 
counties_fire_map <- counties %>%
  left_join(fire_counties, by = ("GEOIDFQ" = "GEOIDFQ"))

#Left join of counties_fire_map and sfdata
sf_fire_map <- counties_fire_map %>%
  left_join(sfdata, by = c("NAME.y" = "County"))



#Checking join 
view(counties_fire_map)

#First check of spatial join
tm_shape(counties_fire_map) +
  tm_polygons("RISK_NATIONAL_RANK", palette = "Oranges", title = "Fire Risk by County")




#Obtaining decennial census data - Still WIP 

#add census api key 
census_api_key("d8e70ec497afa3b6b418a25584fa0ced9492fb59", install = TRUE, overwrite = TRUE)
readRenviron("~/.Renviron")


#Downloading county data for 2020

census_variables <- load_variables(year = 2020, dataset = "pl")
View(census_variables)


options(tigris_use_cache = TRUE)
decennial_data <- get_decennial(geography = "county",
                                 year = "2020",
                                 variables = "P1_001N", ,
                                 geometry = FALSE,
                                 show_progress = FALSE)

view(decennial_data)

