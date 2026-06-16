# Final Project: [Insert Project Title]

Authors: [Your Full Name]  
Course: PUBH 6199 – Visualizing Data with R  
Date: [Insert Date]

## 🔍 Project Overview

[Write 2–3 sentences about your topic and what your project aims to explore or visualize.]

## 📊 Final Write-up

The final write-up, including code and interpretation of the visualizations, is available here:

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
