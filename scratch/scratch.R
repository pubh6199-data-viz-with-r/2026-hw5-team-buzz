# optional, save your exploration code here
data <- read_csv("data/SF_NPL_data.csv")%>%
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
