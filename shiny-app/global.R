install.packages("tmap") 
install.packages("tigris")
install.packages("leaflet")
install.packages("tidycensus")
install.packages("readxl")
install.packages("plotly")
install.packages("bslib")
install.packages("shinythemes")
install.packages("showtext")
library(tidyverse)
library(tmap)
library(sf)
library(tigris)
library(leaflet)
library("tidyverse")
library(dplyr)
library(tidycensus)
library(stringr)
library(readxl)
library(plotly)
library(bslib)
library(shinythemes)
library(showtext)
library(ggplot2)

#Loading above packages to facilitate plotting and visual redesign


#Adding ubuntu font to streamline visualization appearances
font_add_google("Ubuntu", "ubuntu")
showtext_auto()
print(font_families())



#SUPERFUND DATA CLEANING

sfdata <- read_csv("app-data/SF_NPL_data.csv")%>%
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
  drop_na(County)



#FIRE DATA CLEANING 


#reading excel file target sheet to a CSV file 
fire_counties <- read_excel("app-data/fire_dataset.xlsx", sheet = "Counties")

#mutating fire county field to be all upper case with the "COUNTY at the end dropped, to match Superfund and county shapefile fields
fire_counties <- fire_counties %>%
  mutate(NAME = str_remove(NAME, ",.*")) %>%
  mutate(NAME = toupper(NAME)) %>%
  mutate(NAME = str_remove(NAME, " COUNTY")) %>%
  mutate(COUNTYFP = as.character(COUNTYFP))

options(tigris_use_cache = TRUE)

#pull US state boundaries from tigris 

state_boundaries <- states(cb = TRUE, resolution = "20m") %>%
  st_transform(crs = 4326)

#assigning counties to a dataframe
counties <- tigris::counties(cb = TRUE, year = 2025) 

#changing county names to all upper case and removing VI
counties <- counties %>%
  filter(!STATEFP %in% "78") %>%
  mutate(NAME = toupper(NAME))

#Left join of fire and county shapefiles 
counties_fire_map <- counties %>%
  left_join(fire_counties, by = ("GEOIDFQ" = "GEOIDFQ"))

#change map projection for counties to match sf site projections
counties_fire_map <- st_transform(counties_fire_map, crs = 4326)


# PLOT 2 WORK: Resource: https://rpubs.com/snijesh/quadrant-plots

#Reading in data to sf_data frame
sf_data <-  read_csv("app-data/sfdata_clean.csv")

anyNA(sf_data)
which(is.na(sf_data), arr.ind = TRUE)

#grouping to create table with just county, region, state, and count
sf_data_bycounty <-sf_data %>%
  group_by(County, Region, State) %>%
  summarise(sf_count = n()) %>%
  ungroup()

#Arranging descending
sf_data_bycounty %>%
  arrange(desc(sf_count))

anyNA(sf_data_bycounty)
which(is.na(sf_data_bycounty), arr.ind = TRUE)

#DATA CLEANING PT 2: Discovered there are some name discrepancies in the fire and SF data sets

anyNA(fire_counties)
which(is.na(fire_counties), arr.ind = TRUE)

#ACADIA PARISH in fire data = ACADIA in sf data
fire_counties$NAME[1115] <- "ACADIA"
#DOÑA ANA in fire = DONA ANA in sf data
fire_counties$NAME[1804] <- "DONA ANA"
#LAPORTE in fire = LA PORTE in sf 
fire_counties$NAME[744] <- "LA PORTE"
#LASALLE in fire = LA SALLE in sf
fire_counties$NAME[646] <- "LA SALLE"
#LIVINGSTON PARISH in fire = LIVINGSTON in sf
fire_counties$NAME[1146] <- "LIVINGSTON"
#ST. TAMMANY PARISH in fire = ST. TAMMANY in sf
fire_counties$NAME[1166] <- "ST. TAMMANY"
#UNION PARISH in fire = UNION in sf
fire_counties$NAME[1170] <- "UNION"
#WEBSTER PARISH in fire = WEBSTER in sf
fire_counties$NAME[1174] <- "WEBSTER"
#WINN PARISH in fire = WINN in sf
fire_counties$NAME[1178] <- "WINN"

#Connecticut counties have been switched to planning districts / change in SF dataset

sf_data_CTedit <- sf_data 

sf_data_CTedit$County[39] <- "WESTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[64] <- "GREATER BRIDGEPORT PLANNING REGION"
sf_data_CTedit$County[72] <- "CAPITOL PLANNING REGION"
sf_data_CTedit$County[4] <- "NORTHWEST HILLS PLANNING REGION"
sf_data_CTedit$County[23] <- "LOWER CONNECTICUT RIVER VALLEY PLANNING REGION"
sf_data_CTedit$County[70] <- "NAUGATUCK VALLEY PLANNING REGION"
sf_data_CTedit$County[41] <- "NAUGATUCK VALLEY PLANNING REGION"
sf_data_CTedit$County[5] <- "NAUGATUCK VALLEY PLANNING REGION"
sf_data_CTedit$County[49] <- "SOUTHEASTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[30] <- "NORTHEASTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[42] <- "NORTHEASTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[90] <- "NORTHEASTERN CONNECTICUT PLANNING REGION"

#Alaska also mismatched
sf_data_CTedit$County[1115] <- "FAIRBANKS NORTH STAR BOROUGH"

#regrouping to create table with just county, region, state, and count
sf_data_bycounty <-sf_data_CTedit %>%
  group_by(County, Region, State) %>%
  summarise(sf_count = n()) %>%
  ungroup()

counties_fire_sf <- sf_data_bycounty %>%
  left_join(fire_counties, by = c("County" = "NAME", "State" = "STUSPS"))

anyNA(counties_fire_sf)
which(is.na(counties_fire_sf), arr.ind = TRUE)

counties_fire_sf_clean <- counties_fire_sf

#Washington DC is missing because it's not a county. Pulled in national risk score from other excel tab,
#so that column 18 row 157 shows 6% (0.06)
counties_fire_sf_clean$RISK_NATIONAL_RANK[157] <- 0.06

# EPA Region mapping
epa_regions <- list(
  "Region 1 - New England" = c("CT", "ME", "MA", "NH", "RI", "VT"),
  "Region 2 - New York/New Jersey" = c("NJ", "NY", "PR"),
  "Region 3 - Mid-Atlantic" = c("DE", "DC", "MD", "PA", "VA", "WV"),
  "Region 4 - Southeast" = c("AL", "FL", "GA", "KY", "MS", "NC", "SC", "TN"),
  "Region 5 - Great Lakes" = c("IL", "IN", "MI", "MN", "OH", "WI"),
  "Region 6 - South Central" = c("AR", "LA", "NM", "OK", "TX"),
  "Region 7 - Midwest" = c("IA", "KS", "MO", "NE"),
  "Region 8 - Mountains & Plains" = c("CO", "MT", "ND", "SD", "UT", "WY"),
  "Region 9 - Pacific Southwest" = c("AZ", "CA", "HI", "NV"),
  "Region 10 - Pacific Northwest" = c("AK", "ID", "OR", "WA")
)

#find the top 5 contaminated media types in the country

top_media <- read_csv("app-data/SF_NPL_data.csv")%>%

  filter(NPL_Status %in% "Currently on the Final NPL")%>%
  filter(Decision_Document_Type %in% "Record of Decision")%>%
  distinct(Site_Name, Media, .keep_all = TRUE)



