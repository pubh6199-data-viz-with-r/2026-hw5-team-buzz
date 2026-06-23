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

The final write-up, including code and interpretation of the visualizations, is available here:

Visualization 1: This is a map layering Superfund sites on top of a choropleth map of wildfire risk by county. 
The western region of the US has a higher number of high fire risk counties than the Eastern and Midwestern US. 
When the Superfund layer is turned on you can zoom in and see that there are many sites that are located in a high fire risk county. 

Visualization 2: A key takeaway from this graph is that there is an unequal level of fire risk compared by EPA region. 
Region 5 has the lowest overall rank around 0.15 while Region 9 has the highest overall rank around 0.90. Region 4 
has the most an even distribution of risk by county ranging from 0.2 to 1. 

Visualization 3:

Data Sources: 


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

👉 [https://yourusername.shinyapps.io/your-app-name](https://yourusername.shinyapps.io/your-app-name)

## 📦 Packages Used

- `tidyverse`
- `ggplot2`
- `quarto`
- `shiny` (if applicable)

## ✅ To-Do or Known Issues

[Optional section for you to note improvements or bugs.]
