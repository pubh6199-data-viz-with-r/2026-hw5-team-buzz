# Server Logic
server <- function(input, output, session) {
  
  # Create the base map
output$map <- renderLeaflet({
  leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addMapPane("polygonPane", zIndex = 410) %>%
    addMapPane("pointPane", zIndex = 420) %>%
    setView(lng = -98.5795, lat = 39.8283, zoom = 4)
})
  
  # Observe fire risk layer toggle
    observe({
      if (input$show_fire_risk) {
        # Create breaks in increments of 0.2
        min_risk <- floor(min(counties_fire_map$RISK_NATIONAL_RANK, na.rm = TRUE) * 5) / 5
        max_risk <- ceiling(max(counties_fire_map$RISK_NATIONAL_RANK, na.rm = TRUE) * 5) / 5
        breaks <- seq(min_risk, max_risk, by = 0.2)
 
      # Explicitly define color palette for fire risk
        breaks <- seq(0, 1, by = 0.2)
        pal <- colorBin(
          palette = c("#FFFFB2", "#FEB24C", "#FD8D3C", "#FC4E2A", "#B10026"),
          domain = c(0, 1),
          bins = breaks,
          na.color = "#E0E0E0"
        )
      
      # Add fire risk choropleth layer
      leafletProxy("map") %>%
        clearGroup("fire_risk") %>%
        addPolygons(
          data = counties_fire_map,
          fillColor = ~pal(RISK_NATIONAL_RANK),
          fillOpacity = 0.6,
          color = "#BDBDC3",
          weight = 1,
          group = "fire_risk",
          options = pathOptions(pane = "polygonPane"),,
          popup = ~paste0(
            "<strong>County:</strong> ", NAME.y, "<br>",
            "<strong>State:</strong> ", STATE_NAME.y, "<br>",
            "<strong>Risk Score:</strong> ", round(RISK_NATIONAL_RANK, 2), "<br>"
          ),
          highlightOptions = highlightOptions(
            weight = 2,
            color = "#666",
            fillOpacity = 0.7,
            bringToFront = TRUE
          )
        ) %>%
        addLegend(
          position = "bottomright",
          pal = pal,
          values = counties_fire_map$RISK_NATIONAL_RANK,
          title = "Fire Risk Score",
          layerId = "fire_risk_legend",
          na.label = "No Data"
        )
    } else {
      leafletProxy("map") %>%
        clearGroup("fire_risk") %>%
        removeControl("fire_risk_legend")
    }
  })
  
  # Observe superfund sites layer toggle
  observe({
    if (input$show_superfund) {
      # Add superfund sites as markers
      leafletProxy("map") %>%
        clearGroup("superfund") %>%
         addCircleMarkers(
          data = sfdata,
          lng = ~Longitude,
          lat = ~Latitude,
          radius = 5,
          color = "#0066CC",
          fillColor = "#3399FF",
          fillOpacity = 0.8,
          weight = 2,
          group = "superfund",
          options = pathOptions(pane = "pointPane"),
          popup = ~paste0(
            "<strong>Site:</strong> ", Site_Name, "<br>",
            #"<strong>County:</strong> ", County, "<br>",
            #"<strong>State:</strong> ", State, "<br>",
            "<strong>Contamination Type:</strong> ", Media_Types, "<br>"
          )
        )
    } else {
      leafletProxy("map") %>%
        clearGroup("superfund")
    }
  })
 
  observeEvent(input$epa_region, {
    if (input$epa_region == "") {
      # If no region selected, show all states or empty
      updateSelectInput(session, "state", 
                        choices = c("None" = ""),
                        selected = "")
    } else {
      # Get states for the selected EPA region
      states_in_region <- epa_regions[[input$epa_region]]
      
      updateSelectInput(session, "state",
                        choices = c("None" = "", states_in_region),
                        selected = "")
    }
  }) 
  
  # Render the boxplot
  output$risk_boxplot <- renderPlot({
    ggplot(counties_fire_sf_clean, 
           aes(x = fct_reorder(Region, RISK_NATIONAL_RANK), 
               y = RISK_NATIONAL_RANK, 
               group = Region)) +
      geom_boxplot(outlier.shape = NA) +
      geom_jitter(width = 0.2, alpha = 0.5) +
      theme_classic() +
      labs(
        x = "EPA Region",
        y = "Risk National Rank",
        title = "Distribution of Fire Risk Rankings by Region"
      ) +
      theme(
        axis.text.x = element_text(angle = 45, hjust = 1),
        plot.title = element_text(size = 14, face = "bold")
      )
  })
}
