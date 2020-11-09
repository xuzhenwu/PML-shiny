library(shiny)
library(leaflet)

data = data.frame(x = c(1,2,3), y = c(1,2,3))

ui <- fluidPage(
  tags$head(tags$style(
    type = "text/css",
    "#controlPanel {background-color: rgba(255,255,255,0.8);}",
    ".leaflet-top.leaflet-right .leaflet-control {
      margin-right: 210px;
    }"
  )),
  
  leafletOutput(outputId = "map", width="100%"),
  absolutePanel(top = 10, right = 10, height = 100, width=210, id = "controlPanel",
                strong("Put Legend To the Left of Me"))
)

server <- function(session, input, output) {
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addMarkers(data = data, lat = data$x, lng = data$y) %>%
      addLegend(colors = data$x, labels = data$y, title = "Legend")
  })  
}

shinyApp(ui, server)