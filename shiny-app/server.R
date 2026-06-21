# Server Logic
server <- function(input, output, session) {
  
  # Create the base map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      setView(lng = -98.5795, lat = 39.8283, zoom = 4)
  })
  
  # Observe fire risk layer toggle
  observe({
    if (input$show_fire_risk) {
      # Add fire risk choropleth layer
      # Note: This example assumes you have polygon geometries in fire_risk_data
      # Adjust based on your actual data structure
      
      leafletProxy("map") %>%
        clearGroup("fire_risk") %>%
        addPolygons(
          data = fire_risk_data,
          fillColor = ~risk_palette(risk_level),
          fillOpacity = 0.6,
          color = "#BDBDC3",
          weight = 1,
          group = "fire_risk",
          popup = ~paste0(
            "<strong>Region:</strong> ", region, "<br>",
            "<strong>Risk Level:</strong> ", risk_level
          )
        ) %>%
        addLegend(
          position = "bottomright",
          pal = risk_palette,
          values = fire_risk_data$risk_level,
          title = "Fire Risk Level",
          layerId = "fire_risk_legend"
        )
    } else {
      leafletProxy("map") %>%
        clearGroup("fire_risk") %>%
        removeControl("fire_risk_legend")
    }
  })
  