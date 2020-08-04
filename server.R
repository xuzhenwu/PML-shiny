# dependence.R
source("plottrend.R")
source("plotmap.R")







# Define server logic required to draw a histogram ----
server <- function(input, output) {
  

  
  output$plotmap <- renderLeaflet({
    plotmap(input$varname_map)
  })
  
  output$plottrend <- renderPlotly({
    plottrend()
  })
  
}

