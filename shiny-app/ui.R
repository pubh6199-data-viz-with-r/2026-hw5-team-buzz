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
      
      h4("EPA Region Selection"),
      selectInput(
        "epa_region",
        "Highlight EPA Region:",
        choices = c("None" = "", names(epa_regions)),
        selected = ""
      ),
      
      selectInput(
        "state",
        "Select State:",
        choices = c("None" = ""),
        selected = ""
      ),
      
      h5("Legend"),
      p(strong("Fire Risk:"), "Counties colored from yellow (low) to red (high)"),
      p(strong("Superfund Sites:"), "Blue markers indicate NPL site locations"),
      
      hr(),
      
      h5("About the Data"),
      p("Fire risk data from county-level fire dataset."),
      p("Superfund sites are currently on the Final National Priorities (Superfund) List with Record of Decision.")
    ),
    
    mainPanel(
      width = 9,
      fluidRow(
        column(
          width = 9,
          leafletOutput("map", height = "500px")
        ),
          column(
            width = 3,
            wellPanel(
              p("x% of Superfund sites are in high-risk areas")
            ),
            wellPanel(
              p("fact 2"),
            )
          )
        ),
      fluidRow(
        column(
          width = 6,
          h4("Fire Risk National Rank by Region"),
          plotlyOutput("risk_boxplot", height = "350px")
        ),
        column(
          width =6, 
          h5("Media Distribution by State"),
          plotlyOutput("media_barplot", height = "350px"),
        )
      )
    )
  )
)
