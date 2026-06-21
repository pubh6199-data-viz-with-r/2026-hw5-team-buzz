# UI Definition
ui <- fluidPage(
  titlePanel("Fire Risk and Superfund Sites Map"),
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Map Controls"),
      p("This map displays fire risk levels by county as a choropleth map with superfund sites overlaid as points."),
      hr(),
      
      checkboxInput(
        "show_fire_risk",
        "Show Fire Risk Layer",
        value = TRUE
      ),
      
      checkboxInput(
        "show_superfund",
        "Show Superfund Sites",
        value = TRUE
      ),
      
      hr(),
      
      h5("Legend"),
      p(strong("Fire Risk:"), "Counties colored from yellow (low) to red (high)"),
      p(strong("Superfund Sites:"), "Blue markers indicate NPL site locations"),
      
      hr(),
      
      h5("About the Data"),
      p("Fire risk data from county-level fire dataset."),
      p("Superfund sites are currently on the Final NPL with Record of Decision.")
    ),
    
    mainPanel(
      width = 9,
      leafletOutput("map", height = "600px")
    )
  )
)
