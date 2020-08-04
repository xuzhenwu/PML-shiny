# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # dependence.R
  source("plottrend.R")
  source("plotmap.R")
  
  
  output$plotmap <- renderLeaflet({
    plotmap(input$dir,
            input$varname_map,
            input$resolution/10)
  })
  
  output$plottrend <- renderPlotly({
    plottrend(input$dir)
  })
  
}


#shinyApp(ui = ui, server = server)
#rsconnect :: deployApp(PMLshiny)