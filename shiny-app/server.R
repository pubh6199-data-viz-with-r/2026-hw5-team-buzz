# Server Logic
server <- function(input, output, session) {
  region_name_to_code <- setNames(
    sprintf("%02d", 1:10),
    names(epa_regions)
  )
  
  # Create the base map
output$map <- renderLeaflet({
  leaflet() %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addMapPane("borderPane", zIndex = 420) %>%
    addMapPane("polygonPane", zIndex = 410) %>%
    addMapPane("pointPane", zIndex = 430) %>%
    setView(lng = -98.5795, lat = 39.8283, zoom = 4) %>%
    addPolygons(
      data = state_boundaries,
      fill = FALSE,
      color = "black",
      weight = 1.5,
      opacity = 1,
      options = pathOptions(pane = "borderPane"),
      group = "state_borders"
    )
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
          options = pathOptions(pane = "polygonPane"),
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
    
  #Highlight states in selected EPA region
    
  observe({
      proxy <- leafletProxy("map")
      
      # Always clear any previous highlight first
      proxy %>% clearGroup("region_highlight")
      
      # If a specific region is selected, highlight its states
      if (input$epa_region != "None") {
        selected_states <- epa_regions[[input$epa_region]]
        
        region_sf <- state_boundaries %>%
          filter( STUSPS %in% selected_states)
        
        proxy %>%
          addPolygons(
            data    = region_sf,
            fill    = FALSE,
            color   = "black",
            weight  = 3,
            opacity = 1,
            options = pathOptions(pane = "borderPane"),
            group   = "region_highlight"
          )
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
  
  # EPA Region drop down menu 
 
  observeEvent(input$epa_region, {
    message("epa_region: ", input$epa_region)
    message("states: ", paste(epa_regions[[input$epa_region]], collapse=", "))
    if (input$epa_region == "") {
       #If no region selected, show all states or empty
      updateSelectInput(session, "state", 
                       choices = c("None" = ""),
                       selected = "")
    } else {
     #  Get states for the selected EPA region
     states_in_region <- epa_regions[[input$epa_region]]
      
      updateSelectInput(session, "state",
                        choices = c("None" = "", states_in_region),
                       selected = "")
    }
  }) 

  
  #RENDER BARCHART
  
    output$media_barplot <- renderPlot({
      showtext_begin()
      
 #Nationwide View if state is not selected
      
      if (is.null(input$state) || input$state == "") {

        plot_data <- top_media %>%
          mutate(Media = as.character(Media)) %>%
          mutate(
            Media = ifelse(Media == "Other", "Other (specified)", Media),
            Media = fct_other(
              Media,
              keep = c("Groundwater", "Soil", "Sediment", "Surface Water")
            )
          ) %>%
          group_by(Media) %>%
          summarise(Count = n(), .groups = "drop") %>%
          arrange(desc(Count))
        
        plot_title <- "Contaminated Media Types Nationwide"
        
      } else {
        
  #State View once state is selected 
        
    plot_data <- top_media %>%
      filter(State == input$state) %>%
      mutate(Media = as.character(Media)) %>%
      mutate(
        Media = ifelse(Media == "Other", "Other (specified)", Media),
        Media = fct_other(
        Media,
        keep = c("Groundwater", "Soil", "Sediment", "Surface Water")
      )) %>%
      group_by(Media) %>%
      summarise(Count = n(), .groups = "drop") %>%
      arrange(desc(Count))
    
    if (nrow(plot_data) == 0){
      return(
        ggplot() +
          annotate("text", x = 0.5, y = 0.5,
                   label = paste("No Superfund site data available for", input$state),
                   size = 5, color = "gray40") +
          theme_void()
      )
    }
    
    plot_title <- paste("Contaminated Media Types in", input$state)
      }
     
    
      p <- ggplot(plot_data, aes(x = reorder(Media, Count), y = Count, fill = Media)) +
      geom_col(show.legend = FALSE) +
      coord_flip() +
      scale_fill_manual(
        values = c(
          "Groundwater"   = "#B10026",
          "Soil"          = "#FC4E2A",
          "Sediment"      = "#FEB24C",
          "Surface Water" = "#FFFFB2",
          "Other"         = "#BDBDC3"
        )
      ) +
      labs(
        title = plot_title,
        x     = "Media Type",
        y     = "Number of Sites"
      ) +
      theme_classic(base_family = "ubuntu") +
      theme(
        plot.title         = element_text(family = "ubuntu", size = 24),
        axis.text          = element_text(family = "sans", size = 16),
        axis.title         = element_text(family = "sans", size = 16),
        panel.grid.major.y = element_blank()
      )
   
   showtext_end()
   p
})
  
    
  # Render the boxplot
    
  output$risk_boxplot <- renderPlotly({
    current_selection <- input$epa_region
    plot_data <- counties_fire_sf_clean
    plot_data$Region <- fct_reorder(plot_data$Region, plot_data$RISK_NATIONAL_RANK)
    
    if (current_selection == "") {
      plot_data$highlight <- "normal"
      plot_data$alpha_val <- 1 
      
  # Once EPA region is selected, highlight the region and gray the others 
      
    } else {
        selected_code <- region_name_to_code[[current_selection]]
        
        plot_data$highlight <- ifelse(
          as.character(plot_data$Region) == selected_code,
          "selected", "grayed"
        )
        plot_data$alpha_val <- ifelse(
          as.character(plot_data$Region) == selected_code,
          1, 0.3
        )
    } 
    
   
    plot_data$tooltip <- paste0(plot_data$County, ", ", plot_data$State)
    
    epa_region_labels <- c(
      "01"  = "1",
      "02"  = "2",
      "03"  = "3",
      "04"  = "4",
      "05"  = "5",
      "06"  = "6",
      "07"  = "7",
      "08"  = "8",
      "09"  = "9",
      "10" = "10"
    )
    
  #ggplot inputs with jitter function, change shape of dot for number of SF sites on county level
    p <- ggplot(plot_data, 
           aes(x = Region, 
               y = RISK_NATIONAL_RANK)) +
      geom_boxplot(
        aes(fill = highlight, alpha = alpha_val), 
        outlier.shape = NA) +
      geom_point(
        aes(alpha = alpha_val, 
            color = highlight, 
            size = sf_count,
            text = tooltip), 
        position = position_jitter(width = 0.15, height = 0, seed = 42) 
        ) +
          scale_size_continuous(range = c(0.75, 3)) +
      scale_fill_manual(
        values = c("normal" = "steelblue", "selected" = "steelblue", "grayed" = "gray70")
      ) +
      scale_color_manual(
        values = c("normal" = "black", "selected" = "black", "grayed" = "gray70")
      ) +
      scale_alpha_identity() +
      scale_x_discrete(labels = epa_region_labels) +
      guides(fill = "none", color = "none", alpha = "none") +
      theme_classic() +
      labs(
        x = "EPA Region",
        y = "Risk National Rank"
      ) +
      theme(
        axis.text.x = element_text(size = 12, hjust = 1),
        axis.text.y = element_text(size = 12),
        plot.title = element_text(size = 15, face = "bold"),
        axis.title.x = element_text(size = 12),
        axis.title.y = element_text(size = 12))
     
     ggplotly(p, tooltip = "text")
  })
}
