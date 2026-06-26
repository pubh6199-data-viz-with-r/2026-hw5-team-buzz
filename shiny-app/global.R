library(tidyverse)
library(tmap)
library(sf)
library(tigris)
library(leaflet)
library(dplyr)
library(tidycensus)
library(stringr)
library(readxl)
library(plotly)
library(bslib)
library(shinythemes)
library(ggplot2)

# SUPERFUND DATA
sfdata <- readRDS("app-data/sfdata.rds")
top_media <- readRDS("app-data/top_media.rds")

# FIRE/MAP DATA
state_boundaries <- readRDS("app-data/state_boundaries.rds")
#counties_fire_map <- readRDS("app-data/counties_fire_map.rds")

fire_counties <- read_excel("app-data/fire_dataset.xlsx", sheet = "Counties") %>%
  mutate(NAME = str_remove(NAME, ",.*"),
         NAME = toupper(NAME),
         NAME = str_remove(NAME, " COUNTY"),
         COUNTYFP = as.character(COUNTYFP))

# Name fixes for fire_counties (used in boxplot join)
fire_counties$NAME[1115] <- "ACADIA"
fire_counties$NAME[1804] <- "DONA ANA"
fire_counties$NAME[744]  <- "LA PORTE"
fire_counties$NAME[646]  <- "LA SALLE"
fire_counties$NAME[1146] <- "LIVINGSTON"
fire_counties$NAME[1166] <- "ST. TAMMANY"
fire_counties$NAME[1170] <- "UNION"
fire_counties$NAME[1174] <- "WEBSTER"
fire_counties$NAME[1178] <- "WINN"

# BOXPLOT DATA
sf_data <- read_csv("app-data/sfdata_clean.csv")

sf_data_CTedit <- sf_data
sf_data_CTedit$County[39]   <- "WESTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[64]   <- "GREATER BRIDGEPORT PLANNING REGION"
sf_data_CTedit$County[72]   <- "CAPITOL PLANNING REGION"
sf_data_CTedit$County[4]    <- "NORTHWEST HILLS PLANNING REGION"
sf_data_CTedit$County[23]   <- "LOWER CONNECTICUT RIVER VALLEY PLANNING REGION"
sf_data_CTedit$County[70]   <- "NAUGATUCK VALLEY PLANNING REGION"
sf_data_CTedit$County[41]   <- "NAUGATUCK VALLEY PLANNING REGION"
sf_data_CTedit$County[5]    <- "NAUGATUCK VALLEY PLANNING REGION"
sf_data_CTedit$County[49]   <- "SOUTHEASTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[30]   <- "NORTHEASTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[42]   <- "NORTHEASTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[90]   <- "NORTHEASTERN CONNECTICUT PLANNING REGION"
sf_data_CTedit$County[1115] <- "FAIRBANKS NORTH STAR BOROUGH"

sf_data_bycounty <- sf_data_CTedit %>%
  group_by(County, Region, State) %>%
  summarise(sf_count = n(), .groups = "drop")

counties_fire_sf <- sf_data_bycounty %>%
  left_join(fire_counties, by = c("County" = "NAME", "State" = "STUSPS"))

counties_fire_sf_clean <- counties_fire_sf
counties_fire_sf_clean$RISK_NATIONAL_RANK[157] <- 0.06

# EPA REGIONS
epa_regions <- list(
  "Region 1 - New England"        = c("CT", "ME", "MA", "NH", "RI", "VT"),
  "Region 2 - New York/New Jersey" = c("NJ", "NY", "PR"),
  "Region 3 - Mid-Atlantic"        = c("DE", "DC", "MD", "PA", "VA", "WV"),
  "Region 4 - Southeast"           = c("AL", "FL", "GA", "KY", "MS", "NC", "SC", "TN"),
  "Region 5 - Great Lakes"         = c("IL", "IN", "MI", "MN", "OH", "WI"),
  "Region 6 - South Central"       = c("AR", "LA", "NM", "OK", "TX"),
  "Region 7 - Midwest"             = c("IA", "KS", "MO", "NE"),
  "Region 8 - Mountains & Plains"  = c("CO", "MT", "ND", "SD", "UT", "WY"),
  "Region 9 - Pacific Southwest"   = c("AZ", "CA", "HI", "NV"),
  "Region 10 - Pacific Northwest"  = c("AK", "ID", "OR", "WA")
)
