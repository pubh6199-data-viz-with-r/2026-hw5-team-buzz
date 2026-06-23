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


#The following code block works on a filtered data set to create a unique column for each media type so counts can
# be computed. The same structure can be replicated to get media type counts for the full data set and plot them

#Pivot to long
sf_HR_limited_R9 <- sf_HR_limited %>%
  filter(Region.x %in% "09")


View(sf_HR_limited_R9)

sf_HR_limited_R9_long <- sf_HR_limited_R9 %>%
  separate_rows(Media_Types, sep = ",\\s*")


View(sf_HR_limited_R9_long)

#df long to wide
sf_HR_limited_R9_wide <- sf_HR_limited_R9_long %>%
  mutate(value = 1) %>%
  pivot_wider(
    names_from = Media_Types, 
    values_from = value, 
    values_fill = 0
  )

View(sf_HR_limited_R9_wide)

sf_R9_media_type_count <- sf_HR_limited_R9_wide %>%
  summarise(across(Groundwater:`Liquid Waste`, sum))

View(sf_R9_media_type_count)

sf_R9_media_type_count_long <- sf_R9_media_type_count %>%
  pivot_longer(
    cols = everything(),
    names_to = "MediaTypes",
    values_to = "Counts"
  )

head(sf_R9_media_type_count_long)

#Ranking Regions
sf_HR_limited_states <- sf_HR_limited %>%
  group_by(State) %>%
  summarise(sf_count = n()) %>%
  ungroup()

View(sf_HR_limited_states)

ggplot(sf_HR_limited_byregion, aes(x = fct_reorder(Region.x, sf_count), y = sf_count)) +
  geom_col() +
  coord_flip()


#Exploring R9
sf_HR_limited_R9 <- sf_HR_limited %>%
  filter(Region.x %in% "09")

#End 


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

#assigning counties to a dataframe, removing VI and mutating names
counties <- tigris::counties(cb = TRUE, year = 2025) %>%
  filter(STATEFP != "78") %>%
  mutate(NAME =toupper(NAME))
 

#Checking rename was correct
view(counties)

#Left join of fire and county shapefiles 
counties_fire_map <- counties %>%
  left_join(fire_counties, by = ("GEOIDFQ" = "GEOIDFQ"))

anyNA(counties_fire_map)
which(is.na(counties_fire_map), arr.ind = TRUE)




#Left join of counties_fire_map and sfdata
#sf_fire_map <- counties_fire_map %>%
 # left_join(sfdata, by = c("NAME.y" = "County"))


#Checking join 
view(counties_fire_map)

#First check of spatial join
tm_shape(counties_fire_map, bbox = st_bbox(counties_fire_map)) +
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


counties_fire_map <- counties_fire_map %>%
  left_join(decennial_data, by = c("GEOID.x" = "GEOID"))

view(counties_fire_map)


tm_shape(counties_fire_map_pop, bbox = st_bbox(counties_fire_map_pop)) +
  tm_polygons("value", palette = "Oranges", title = "Population by County")



# PLOT 2 WORK: Resource: https://rpubs.com/snijesh/quadrant-plots

#Reading in data to sf_data frame
sf_data <-  read_csv("shiny-app/app-data/sfdata_clean.csv")
view(sf_data)

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

view(fire_counties)

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

view(fire_counties)


#Connecticut counties have been switched to planning districts / change in SF dataset

sf_data_CTedit <- sf_data 
view(sf_data_CTedit)

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

view(sf_data_CTedit)

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

#Confirm remaining NA values are for islands which are not included in fire dataset; leave for SF data set completeness
View(counties_fire_sf_clean)


#Simple Scatter 
ggplot(counties_fire_sf_clean, aes(x=RISK_NATIONAL_RANK, y=sf_count, color=State ))+
  geom_point()+
  theme_classic()

#Facet Scatter
ggplot(counties_fire_sf_clean, aes(x=RISK_NATIONAL_RANK, y=sf_count, color=State ))+
  geom_point()+
  facet_wrap(~Region, scales = "free") +
  theme_classic()

ggplot(counties_fire_sf_clean, aes(x=RISK_NATIONAL_RANK, y=sf_count, color=State ))+
  geom_point(position = position_jitter())+
  facet_wrap(~Region) +
  theme_classic()

ggplot(counties_fire_sf_clean, aes(x=RISK_NATIONAL_RANK, y=sf_count, color=State ))+
  geom_point(position = position_jitter())+
  facet_wrap(~Region, scales = "free") +
  theme_classic()

ggplot(counties_fire_sf_clean, aes(x=RISK_NATIONAL_RANK, y=sf_count, color=State ))+
  geom_point(position = position_jitter())+
  facet_wrap(~Region, scales = "free_y") +
  theme_classic()

#BoxPlot
ggplot(counties_fire_sf_clean, aes(x = fct_reorder(Region, RISK_NATIONAL_RANK), y = RISK_NATIONAL_RANK, group = Region))+
  geom_boxplot(outlier.shape = NA) +
  geom_jitter(width = 0.2) +
  theme_classic() 
  

View(counties_fire_sf_clean)

#ViolinPlot

install.packages("see", repos = "https://cran.r-project.org") #installing "see" package so I can add individual data points to violin plot

counties_fire_sf_clean%>%
  group_by(Region) %>% #Set up island groups
  ggplot(aes(x = Region, y = RISK_NATIONAL_RANK)) + #establishing aesthetic elements as Region(x) and risk national rank (y)
  see::geom_violindot(size_dots = .1, dots_color = "black") + #setting geometry as violin plot with individual dots, sizing and coloring these dots to be visible
  coord_flip() + # flipping to a horizontal plot
  labs(title = "Violin Plot: National Risk by Region", x = "Region", y = "National Risk Score") +
  theme_minimal() #Setting theme to minimal 


counties_fire_sf_clean%>%
  group_by(Region) %>% 
  ggplot(aes(x = Region, y = RISK_NATIONAL_RANK)) + #establishing aesthetic elements as Region(x) and risk national rank (y)
  see::geom_violindot(position = position_jitter(), size_dots = .1, dots_color = "black") + #setting geometry as violin plot with individual dots, sizing and coloring these dots to be visible
  coord_flip() + # flipping to a horizontal plot
  labs(title = "Violin Plot: National Risk by Region", x = "Region", y = "National Risk Score") +
  theme_minimal() #Setting theme to minimal 


#HeatMap? Maybe try next... 


#Visualization Idea: Population and Fire Risk - This data would need substantial cleaning to carry this forward

counties_fire_sf_clean_pop <- counties_fire_sf_clean %>%
  left_join(decennial_data, by = ("GEOID"))

view(counties_fire_sf_clean_pop)

ggplot(counties_fire_sf_clean_pop, aes(x=RISK_NATIONAL_RANK, y=value, color=State ))+
  geom_point()+
  facet_wrap(~Region, scales = "free") +
  theme_classic()



#Visualization 3 - Distribution of media types

#Question: Among Superfund sites in the highest quartile of risk, what are the most frequent media types and contaminants?

View(counties_fire_sf_clean)

counties_fire_sf_clean_HR <- counties_fire_sf_clean %>%
  filter(RISK_NATIONAL_RANK >= 0.75)

unique(counties_fire_sf_clean_HR$County)

View(counties_fire_sf_clean_HR)

#132 counties are in upper risk quartile 

library(dplyr)
library(tidyr)

sf_data_for_Risk <- read.csv("data/SF_NPL_data.csv") %>%
  #filter by NPL Status and Decision Document
  filter(NPL_Status %in% "Currently on the Final NPL")%>%
  filter(Decision_Document_Type %in% "Record of Decision") %>%
  #remove duplicate media types and site names while keeping the original df
  distinct(Site_Name, Media, .keep_all = TRUE)%>%
  #make a new column with contaminated media type by site
  group_by(Site_Name)%>%
  mutate(Media_Types = toString(Media))%>%
  mutate(Contaminant = toString(Contaminant))%>%
  #remove any duplicate sites by their lat and long coordinates while keeping df
  distinct(Latitude, Longitude, .keep_all = TRUE)%>%
  #remove rows with missing county name 
  drop_na(County) %>%
  filter(County %in% c("ALACHUA", "ALAMEDA", "ATLANTIC", "BAY", "BEAUFORT", "BENTON", "BERNALILLO", "BOULDER", "BRAZORIA", 
         "BREVARD", "BROWARD", "BRUNSWICK", "BURLINGTON", "BUTLER", "BUTTE", "CADDO", "CALHOUN", "CAPE MAY", "CARIBOU",
         "CARSON", "CHARLESTON", "CHAVES", "CIBOLA", "CLACKAMAS", "CLEAR CREEK", "COCHISE", "CONTRA COSTA", "COWLEY", 
         "CREEK", "DAVIS", "DEER LODGE", "DOUGLAS", "DUVAL", "EAGLE", "ELMORE", "ESCAMBIA", "FAIRBANKS NORTH STAR","FAYETTE", 
         "FREMONT", "FRESNO", "GALLATIN", "GALVESTON", "GEARY", "GLYNN", "GRANT", "HARLAN", "HARRISON", "HIDALGO", "HILLSBOROUGH", 
         "HOCKLEY", "HONOLULU", "INDIAN RIVER", "JASPER", "JEFFERSON", "KERN", "KLAMATH", "LAKE", "LARAMIE", "LAWRENCE", 
         "LEWIS AND CLARK", "LINCOLN", "LOS ANGELES", "LYON", "MARICOPA", "MARTIN", "MCCLAIN", "MENDOCINO", "MERCED", "MIAMI-DADE", 
         "MINERAL", "MISSOULA", "MOBILE", "MONTEREY", "MONTGOMERY", "MONTROSE", "MORROW", "NEVADA", "NEW HANOVER", "OCEAN", 
         "OCHILTREE", "ORANGE", "PALM BEACH", "PARKER", "PAYNE", "PENNINGTON", "PIMA", "POLK", "PUEBLO", "RENO", "RICHMOND", 
         "RIO ARRIBA", "RIVERSIDE", "SACRAMENTO", "SALT LAKE", "SAN BERNARDINO", "SAN DIEGO", "SAN JOAQUIN", "SAN JUAN", 
         "SANTA BARBARA", "SANTA CLARA", "SANTA CRUZ", "SANTA ROSA", "SEMINOLE", "SHASTA", "SHOSHONE", "SILVER BOW", "SISKIYOU", 
         "SOCORRO", "SOLANO", "SPOKANE", "ST. TAMMANY", "STANISLAUS", "STEVENS", "SWISHER", "TAOS", "TOOELE", "VENTURA", "VOLUSIA", 
         "WASCO", "WASHINGTON", "WEBER", "YAKIMA", "YAVAPAI", "YELLOWSTONE", "YOLO"))
  
View(sf_data_for_Risk)


#Joining counties_fire_sf_clean_HR with sf_data_for_Risk

sf_HR_analysis <- counties_fire_sf_clean_HR %>%
  left_join(sf_data_for_Risk, by = c("County" = "County", "State" = "State" ))

View(sf_HR_analysis)

unique(sf_HR_analysis$County)
            
#sf_data_HR now represents SF sites in the highest risk quartile for fires (125 counties)

sf_HR_limited <- sf_HR_analysis %>%
  select(County, Region.x, State, RISK_NATIONAL_RANK, Site_Name, Latitude, Longitude, Federal_Facility, Contaminant, Media_Types)

View(sf_HR_limited) #Need to fix Fairbanks North Star


#Ranking Regions
sf_HR_limited_byregion <- sf_HR_limited %>%
  group_by(Region.x) %>%
  summarise(sf_count = n()) %>%
  ungroup()

View(sf_HR_limited_byregion)

ggplot(sf_HR_limited_byregion, aes(x = fct_reorder(Region.x, sf_count), y = sf_count)) +
  geom_col() +
  coord_flip()


#Exploring R9
sf_HR_limited_R9 <- sf_HR_limited %>%
  filter(Region.x %in% "09")


View(sf_HR_limited_R9)

sf_HR_limited_R9_long <- sf_HR_limited_R9 %>%
  separate_rows(Media_Types, sep = ",\\s*")


View(sf_HR_limited_R9_long)


#df long to wide
sf_HR_limited_R9_wide <- sf_HR_limited_R9_long %>%
  mutate(value = 1) %>%
  pivot_wider(
    names_from = Media_Types, 
    values_from = value, 
    values_fill = 0
  )

View(sf_HR_limited_R9_wide)

sf_R9_media_type_count <- sf_HR_limited_R9_wide %>%
  summarise(across(Groundwater:`Liquid Waste`, sum))

View(sf_R9_media_type_count)

sf_R9_media_type_count_long <- sf_R9_media_type_count %>%
  pivot_longer(
    cols = everything(),
    names_to = "MediaTypes",
    values_to = "Counts"
  )

head(sf_R9_media_type_count_long)

library(ggplot2)
library(forcats)

ggplot(sf_R9_media_type_count_long, aes(x = fct_reorder(MediaTypes, Counts), y = Counts)) +
  geom_col() +
  coord_flip()+
  labs(title = "Media Types at High Fire Risk Sites - Region 9", x = "Media Types")+
  theme_classic()


#Exploring R4

sf_HR_limited_R4 <- sf_HR_limited %>%
  filter(Region.x %in% "04")


View(sf_HR_limited_R4)

sf_HR_limited_R4_long <- sf_HR_limited_R4 %>%
  separate_rows(Media_Types, sep = ",\\s*")


View(sf_HR_limited_R4_long)


#df long to wide

sf_HR_limited_R4_wide <- sf_HR_limited_R4_long %>%
  mutate(value = 1) %>%
  pivot_wider(
    names_from = Media_Types, 
    values_from = value, 
    values_fill = 0
  )

View(sf_HR_limited_R4_wide)

sf_R4_media_type_count <- sf_HR_limited_R4_wide %>%
  summarise(across(Groundwater:`Liquid Waste`, sum))

View(sf_R4_media_type_count)

sf_R4_media_type_count_long <- sf_R4_media_type_count %>%
  pivot_longer(
    cols = everything(),
    names_to = "MediaTypes",
    values_to = "Counts"
  )

head(sf_R4_media_type_count_long)

library(ggplot2)
library(forcats)

ggplot(sf_R4_media_type_count_long, aes(x = fct_reorder(MediaTypes, Counts), y = Counts)) +
  geom_col() +
  coord_flip()


#Exploring Region 8
sf_HR_limited_R8 <- sf_HR_limited %>%
  filter(Region.x %in% "08")


View(sf_HR_limited_R8)

sf_HR_limited_R8_long <- sf_HR_limited_R8 %>%
  separate_rows(Media_Types, sep = ",\\s*")


View(sf_HR_limited_R8_long)


#df long to wide

sf_HR_limited_R8_wide <- sf_HR_limited_R8_long %>%
  mutate(value = 1) %>%
  pivot_wider(
    names_from = Media_Types, 
    values_from = value, 
    values_fill = 0
  )

View(sf_HR_limited_R8_wide)

sf_R8_media_type_count <- sf_HR_limited_R8_wide %>%
  summarise(across(Groundwater:`Liquid Waste`, sum))

View(sf_R8_media_type_count)

sf_R8_media_type_count_long <- sf_R8_media_type_count %>%
  pivot_longer(
    cols = everything(),
    names_to = "MediaTypes",
    values_to = "Counts"
  )

head(sf_R8_media_type_count_long)

library(ggplot2)
library(forcats)

ggplot(sf_R8_media_type_count_long, aes(x = fct_reorder(MediaTypes, Counts), y = Counts)) +
  geom_col() +
  coord_flip()





## attempting to separate by contaminant
#i <- 1
#while (i <= nrow(sf_HR_limited_R9_long)) {
#  if (!is.na(sf_HR_limited_R9_long[[i, "Contaminant" ]]) == "1" && i <nrow(sf_HR_limited_R9_long)) {
#    sf_HR_limited_R9_long[[i + 1, "Contaminant"]] <- paste(sf_HR_limited_R9_long[[i, "Contaminant"]], sf_HR_limited_R9_long[[i + 1, "Contaminant"]], sep = ",")
    sf_HR_limited_R9_long <- sf_HR_limited_R9_long[-i,]
#  }else{
 #   i <- i + 1
#  }}

View(sf_HR_limited_R9_long)


#sf_fire_map <- counties_fire_map %>%
#left_join(sfdata, by = c("NAME.y" = "County"))


