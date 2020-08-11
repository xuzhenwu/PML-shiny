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
  source("plottrend.R", encoding = 'UTF-8')
  source("plotmap.R", encoding = 'UTF-8')
  source('trend_table.R', encoding = 'UTF-8')
  
  # reaction
  x1 <- eventReactive(input$simulatemap,{
    plotmap(input$dir,
            input$varname_map,
            input$resolution,
            input$year,
            input$month,
            input$submonth,
            input$lat,
            input$lon,
            input$dist)
  })
  x2 <- eventReactive(input$simulatetrend,{
    plottrend(input$dir,
              input$vars_trend,
              input$lat,
              input$lon,
              input$dist
    )
  })
  x3 <- eventReactive(input$simulatetrend,{
    trend_table(input$dir)
  })
  
  #
  output$plotmap <- renderLeaflet({
    x1()
  })
  output$plottrend <- renderPlotly({
    x2()
  })
  
  output$trendinfo <- renderTable({
    x3()
  })
  
  
  t1 <- eventReactive(input$clickshare,{
  "一个低分辨率(300m)的可用于分享的web apps实例如下
    https://xuzhenwu.shinyapps.io/PML-shiny/ \n "
  })
  
  t2 <- eventReactive(input$clickdeveloper,{
    "如有疑问，可经15521242747联系项目程序开发人员\n  "
  })
  
  output$shareinfo <- renderText(
    t1()
  )
  
  output$developerinfo  <- renderText(
    t2()
  )
  

  
}


#shinyApp(ui = ui, server = server)
#rsconnect :: deployApp(PMLshiny)