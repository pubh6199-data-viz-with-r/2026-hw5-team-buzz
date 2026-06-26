# UI Definition
ui <- fluidPage(theme = shinytheme("united"), #Setting theme, titles 
  titlePanel("Wildfires & Waste: Exploring Compound Environmental Hazards"),
  
  #Establishing left sidebar layout, color, and text 
  sidebarLayout( 
    sidebarPanel(
      style = "background-color: #FFE4C4;",
      width = 3,
      h4("Explore Wildfire Risk and Superfund Sites in Your Area"),
      p("This map displays relative wildfire risk by county, defined as the percent risk that county faces compared with others nationwide. Superfund site locations are overlaid as points. Superfund sites are highly polluted locations that require cleanup strategies, and are regulated by the U.S. Environmental Protection Agency"),
      hr(),
      
      #Input checkboxes for visualizing map layers 
      checkboxInput(
        "show_fire_risk",
        "Show Fire Risk Layer",
        value = FALSE
      ),
      
      checkboxInput(
        "show_superfund",
        "Show Superfund Sites",
        value = FALSE
      ),
      
      #spacing
      hr(),
      
      #Input dropdowns for Regions and State
      h4("Region and State Selection"),
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
      
      hr(),
      
      h4("Legend Details"),
      p(strong("Fire Risk:"), "Counties colored from yellow (low) to red (high)"),
      p(strong("Superfund Sites:"), "Blue markers indicate NPL site locations"),
      
      hr(),
      
      h4("About the Data"),
      p("County-level fire risk data was obtained from the Wildfire Risk to Communities (WRC) website, maintained by the US Department of Agriculture Forest Service."),
      p("Learn more about the data at", a("the WRC Web Page", href = "https://wildfirerisk.org/")),
      p("Superfund site data was obtained from the US Environmental Protection Agency website. Superfund sites are currently on the Final National Priorities (Superfund) List with Record of Decision, indicating a cleanup plan is in place."),
      p("Learn more about the data at", a("the EPA's Superfund Data Web Page", href = "https://www.epa.gov/superfund/superfund-data-and-reports")),
      
      hr(),
      
      h4("App Details"),
      p("This app was created with coding assistance from", a("Shiny Assistant", href = "https://gallery.shinyapps.io/assistant/#"), "and", a("Claude.ai", href = "claude.ai")),
    ),
    
 #Label for map - establishing main panel size   
    mainPanel(
      width = 9,
      fluidRow(
        column(
          width = 9,
          h3(strong("Superfund Site Locations and Wildfire Risk By County")),
          leafletOutput("map", height = "500px")
        ),
 #Cards with important statistics and interpretations
          column(
            width = 3,
            wellPanel(
              style = "background-color: #F08080;",
              p("281 Superfund sites, or 24% of sites, are in high fire risk areas.", style = "font-size: 18px;")
            ),
            wellPanel(
              style = "background-color: #ADD8E6;",
              p("EPA Region 9 (California, Nevada, Arizona, and Hawaii) has the highest median wildfire risk in the country.", style = "font-size: 18px;")
            ), 
            wellPanel(
              style = "background-color: #FFFACD;",
              p("Groundwater is the most frequently contaminated environmental media at Superfund sites, and should be prioritized in future wildfire research.", style = "font-size: 18px;")
            )
          )
        ),
 #Title and placement of boxplot
      fluidRow(
        column(
          width = 6,
          h3(strong("County Fire Risk by EPA Region")),
          plotlyOutput("risk_boxplot", height = "400px")
        ),
 #Title and placement of barchart
        column(
          h5(HTML("&nbsp;")),
          width =6, 
          plotOutput("media_barplot", height = "400px"),
        )
      ),
 #Explanation of boxplot below 
      fluidRow(
        column(
          h5(HTML("&nbsp;")),
          width =6,
          wellPanel(
            style = "background-color: #FFE4C4;",
            p("EPA Regions across the country show different wildfire risk profiles. In this plot, dots represent counties, and are sized based on the number of Superfund sites found in that county.", style = "font-size: 16px;")
          )
        ),
 #Explanation of barchart 
        column(
          h5(HTML("&nbsp;")),
          width = 6,
          wellPanel(
            style = "background-color: #FFE4C4;",
            p("Superfund sites contain different types of contaminated media that might be affected by natural disasters. Bars represent how often each type of contaminated media is found at sites.", style = "font-size: 16px;")
          )
        )
      )
    )
  )
)
