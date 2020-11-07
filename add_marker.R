library(shiny)
library(leaflet)

ui <- fluidPage(
  leafletOutput('map')
)

server <- function(input, output, session) {
  output$map <- renderLeaflet({leaflet()%>%addTiles()})
  
  observeEvent(input$map_click, {
    click = input$map_click
    leafletProxy('map')%>%addMarkers(lng = click$lng, lat = click$lat)
  })
}

shinyApp(ui, server)