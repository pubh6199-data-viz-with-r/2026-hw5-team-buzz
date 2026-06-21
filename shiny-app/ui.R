# UI Definition
ui <- fluidPage(
  title = "Fire Risk and Superfund Sites Map",

  
  sidebarLayout = sidebarPanel(
    width = 300,
    h4("Map Controls"),
    p("This map displays fire risk levels as a choropleth map with superfund sites overlaid as points."),
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
    p(strong("Fire Risk:"), "Areas colored from yellow (low) to red (high)"),
    p(strong("Superfund Sites:"), "Blue markers indicate site locations")
  ),
  
  card(
    card_header("Fire Risk and Superfund Sites"),
    leafletOutput("map", height = "600px")
  )
)
