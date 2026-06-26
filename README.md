[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/jEmP5upM)
# Final Project: Exploration of Fire Risk around Superfund Sites 

Authors: Abby Schmitt and Sharon Hertzell  
Course: PUBH 6199 – Visualizing Data with R  
Date: 6/21/2026

## 🔍 Project Overview

Wildfire risk across the US is increasing due to climate change, with some regions facing disproportionately high exposure. 
Superfund sites in these high-risk areas are especially concerning, as wildfires can combust toxic chemicals and spread contamination into the surrounding atmosphere. 
This app aims to visualize the relationship between wildfire risk and Superfund site distribution to highlight where remediation strategies should account for fire risk.

## 📊 Final Write-up

The final write-up, including code and interpretation of the visualizations, is available here.

Visualization 1: This is a map layering Superfund sites on top of a choropleth map of wildfire risk by county. 
The western region of the US has a higher number of high fire risk counties than the Eastern and Midwestern US. 
When the Superfund layer is turned on you can zoom in and see that there are many sites that are located in a high fire risk county. 

Visualization 2: A key takeaway from this graph is that there is an unequal level of fire risk compared by EPA region. 
Region 5 has the lowest overall rank around 0.15 while Region 9 has the highest overall rank around 0.90. Region 4 
has the most an even distribution of risk by county ranging from 0.2 to 1. 

Visualization 3: This barplot shows how many sites in a given state contain the top 4 contaminated media in the country. 
These media are groundwater, soil, sediment, and surface water. These exist as different levels and can inform how a wildfire may further contaminate these sources. 


Data Sources: Our first data source is the Superfund site National Priority List (NPL) from the EPA website. 
This has a list of current and deleted sites as well as the location, contaminated media, and the type of contaminants found at the site.
Cleaning this data consisted of filtering sites that are currently on the NPL list and decision document only through Record of Decision. 
Sites that have a missing county were not considered for this analysis since we are comparing fire risk by county. 

Our second data source is a wildfire risk dataset from the USDA Forest Service. This dataset contains the risk score on a county level as well as the GEOID on the county level. 
This set was merged with tigris county shapefiles for mapping.  


👉 [**View the write-up website**](https://pubh6199-data-viz-with-r.github.io/hw6-YOUR-TEAM-NAME/)

## 📂 Repository Structure

```plaintext
.
├── _quarto.yml          # Quarto configuration file
├── .gitignore           # Files to ignore in git
├── data/                # Cleaned data files used in project
├── .Rproj               # RStudio project file
├── index.qmd            # Main Quarto file for final write-up
├── scratch/             # Scratch files for exploratory analysis         
├── shiny-app/           # Shiny app folder (if used)
│   ├── app.R
|   ├── www/             # Static files for Shiny app (CSS, JS, images)
│   └── app-data/        # Data files for Shiny app
├── docs/                # Rendered site (auto-generated)
└── README.md            # This file
```

## 🛠 How to Run the Code

### To render the write-up:

1. Open the `.Rproj` file in RStudio.
2. Open `index.qmd`.
3. Click **Render**. The updated html will be saved in the `docs/` folder.

### To run the Shiny app (if applicable):

```r
shiny::runApp("shiny-app")
```

> ⚠️ Make sure any necessary data files are in `shiny-app/app-data/`.

## 🔗 Shiny App Link

If your project includes a Shiny app, you can access it here:

👉 [https://6ybexz-abigail-schmitt.shinyapps.io/shiny-app/](https://6ybexz-abigail-schmitt.shinyapps.io/shiny-app/)

## 📦 Packages Used

- `tidyverse`
- `ggplot2`
- `quarto`
- `shiny` (if applicable)
- `tmap`
-`tigris`
- `leaflet`
- `tidycensus`
- `readxl`
- `plotly`
- `bslib`
- `shinythemes`
- `showtext`


## ✅ To-Do or Known Issues

Prototype Update: 

For our prototype V1 we have drop down menus for user interaction for EPA region and states within that region. 
These menus are only in our UI and have not yet been integrated into our server so they are not reactive to the visualizations yet.
We plan on having the user select an EPA region and the states in that region will be highlighted on the leaflet map. 
Once that is selected, in our second visualization the boxplot of the selected region will be highlighted while the other region boxplots will be gray. 
The selected EPA region will be reactive to the second drop down menu which will only show the states in that region. The user can select a state and that will trigger the third visualization 
to show a horizontal barchart of the ranked contaminated media types by state. 

We also need to add more context to our dashboard through explicit labeling, colors, and explanation of the data since this information is not yet adapted to a lay audience. 
We plan on changing the theme to make it more visually appealing. 


Final Update: We would like to add more data on contamination, and explore adding population and demographic layers to the map
