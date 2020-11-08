library(DT)
library(shiny)

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      selectInput("amountTable", "Amount Tables", 1:10, 3)
    ),
    mainPanel(
      # UI output
      uiOutput("dt")
    )
  )
)

server <-  function(input, output, session) {
  observe({
    lapply(1:input$amountTable, function(amtTable) {
      output[[paste0('T', amtTable)]] <- DT::renderDataTable({
        iris[1:amtTable, ]
      })
    })
  })
  
  output$dt <- renderUI({
    tagList(lapply(1:input$amountTable, function(i) {
      dataTableOutput(paste0('T', i))
    }))
  })
  
}

shinyApp(ui, server)