library(shiny)
library(leaflet)
library(dplyr)
library(sf)

# buildings <- st_read("E:/QL_2022/lidar_3d_city_modelling/scripts/R/shiny_test/data/building_footrpint_NS56NE.shp")
# buildings <- st_transform(buildings, crs = 4326)
# st_write(buildings, "E:/QL_2022/lidar_3d_city_modelling/scripts/R/shiny_test/data/building_footrpint_NS56NE_wgs84.shp")
# 
# trees <- st_read("E:/QL_2022/lidar_3d_city_modelling/scripts/R/shiny_test/data/NS56NE_TreeTops.shp")
# trees <- st_transform(trees, crs = 4326)
# st_write(trees, "E:/QL_2022/lidar_3d_city_modelling/scripts/R/shiny_test/data/NS56NE_TreeTops_wgs84.shp")

buildings <- st_read("E:/to_github/shiny_test/data/building_footrpint_NS56NE_wgs84.shp")
trees <- st_read("E:/to_github/shiny_test/data/NS56NE_TreeTops_wgs84.shp")

ui <- fluidPage(
  tags$head(
    tags$style(type = "text/css", "html, body {width:100%;height:100%;margin:0;padding:0;}"),
    tags$style(type = "text/css", "#map {height:100vh !important;}")
  ),
  leafletOutput("map", width = "100%", height = "100%")
)

server <- function(input, output, session) {
  output$map <- renderLeaflet({
    # Define color palettes
    building_pal <- colorNumeric("YlOrRd", domain = buildings$MEAN)
    tree_pal <- colorNumeric("Greens", domain = trees$Z)
    
    # Create the leaflet map
    leaflet() %>%
      addTiles() %>%
      
      # Add building polygons
      addPolygons(
        data = buildings,
        fillColor = ~building_pal(MEAN),
        color = "black",                  # Outline color
        weight = 1,                       # Outline thickness
        fillOpacity = 0.7,                # Transparency of the fill color
        popup = ~paste("Building Height:", MEAN, "m")  # Popup text
      ) %>%
      
      # Add tree points
      addCircleMarkers(
        data = trees,
        radius = ~Z / 2,             # Marker size based on height
        fillColor = ~tree_pal(Z),    # Color based on height
        color = "black",                  # Outline color
        weight = 1,                       # Outline thickness
        fillOpacity = 0.8,                # Transparency of the fill color
        popup = ~paste("Tree ID:", U_ID, "<br>", "Tree Height:", Z, "m")  # Popup text
      ) %>%
      
      # Add legends for both layers
      addLegend(
        pal = building_pal, 
        values = ~building$MEAN, 
        title = "Building Height (m)", 
        position = "bottomleft"
      ) %>%
      addLegend(
        pal = tree_pal, 
        values = ~trees$Z, 
        title = "Tree Height (m)", 
        position = "bottomright"
      )
  })
}

shinyApp(ui, server)