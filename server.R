library(shiny)
library(leaflet)
library(raster)
library(rgdal)
library(leaflet)
library(RColorBrewer)
library(reshape2)
library(plotly)
library(gapminder)
library(ggplot2)
library(rsconnect)
library(shinyFiles)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # dependence.R
  source("plottrend.R")
  source("plotmap.R")
  
  
  # 
  output$plotmap <- renderLeaflet({
    
    plotmap( input$dir,
             input$varname_map,
             input$resolution,
             input$year,
             input$month,
             input$submonth,
             input$lat,
             input$lon,
             input$dist)
  })
  
  output$plottrend <- renderPlotly({
    plottrend(input$dir,
              input$vars_trend,
              input$lat,
              input$lon,
              input$dist
              )
  })
  
}


#shinyApp(ui = ui, server = server)
#rsconnect :: deployApp(PMLshiny)