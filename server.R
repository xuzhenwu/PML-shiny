# Define server 
server <- function(input, output) {
  
  # dependence.R
  source("plottrend.R", encoding = 'UTF-8')
  source("plotmap.R", encoding = 'UTF-8')
  source('trend_table.R', encoding = 'UTF-8')
  
  
  #==============================================================================
  # leaflet related
  #==============================================================================
  # base map
  output$map <- renderLeaflet({
    leaflet() %>% 
      setView(116.390833, 39.91194,  zoom = 13) %>% # the Forbidden City
      addTiles()
  })
  
  # add markers and tables
  values <- reactiveValues()
  values$table <- data.table(name = character(), lng = numeric(), lat = numeric(), dist = numeric())
  print(isolate(values$table))
  print("s1")
  
  observe({
    #print(values$table)
    if(!is.null(input$map_click$lng)){
      click = input$map_click
      newLine <- isolate(data.table(name = "未命名", lng = click$lng, lat = click$lat, dist = input$dist))
      print(newLine)
      isolate(values$table <- rbind(values$table, newLine))
    }
    
  })
  output$table <- renderDataTable(values$table,
                                  options = list(
                                    paging = TRUE,
                                    searching = TRUE,
                                    fixedColumns = TRUE,
                                    autoWidth = TRUE,
                                    ordering = TRUE,
                                    dom = 'Bfrtip',
                                    buttons = c('csv', 'excel')
                                  ),
                                  selection = 'none',
                                  editable = TRUE,
                                  rownames = TRUE,
                                  extensions = 'Buttons',
                                  class = "display"
  )
  observeEvent(input$table_cell_edit, {
    values$table[input$table_cell_edit$row,input$table_cell_edit$col] <<- input$table_cell_edit$value
  })

  
  
  # to see if this pare
  # observeEvent(input$banking.df_data_cell_edit, {
  #   d1[input$banking.df_data_cell_edit$row,input$banking.df_data_cell_edit$col] <<- input$banking.df_data_cell_edit$value
  # })
  
  # add marker and buffer circle by clicking
  
  update_marker <- function(){
    
    leafletProxy('map')%>%
      clearMarkers() %>%
      clearShapes()
    
    nrow <- nrow(values$table)
    if(nrow != 0){
      
      data   <- values$table
      sf_point <- st_as_sf(data, coords = c("lng", "lat")) %>% 
        st_set_crs(4326)%>% 
        st_transform(crs = 2436)
      st_circle <- st_buffer(sf_point, data$dist)%>% 
        st_transform(crs = 4326)
      
      leafletProxy('map')%>%
        addPolylines(data = st_circle, color = "black",
                     weight = 1.5,
                     opacity = 0.8, fillOpacity = 0.2)%>%
        addMarkers(lng = values$table$lng, lat = values$table$lat)
    }
    
  }
  observeEvent(input$map_click, {
    update_marker()
  })
  observeEvent(input$table_cell_edit, {
    update_marker()
  })
  
  # clear all markers by clearallpoints buttom
  observeEvent(input$clearallpoints, {
    values$table <- data.table(name = NULL, lng = NULL, lat = NULL, dist = NULL)
    # cant use update marker fun as it only allows add new marker
    update_marker()
    
  })
  # clear last markers
  observeEvent(input$clearlastpoints, {
    print(nrow(values$table))
    max_row <- nrow(values$table) - 1
    if(max_row > 0)
      values$table <- values$table[1:max_row,]
    else
      values$table <- data.table(name = NULL, lng = NULL, lat = NULL, dist = NULL)
    update_marker()
    
  })
  
  
  
  # add raster map by deploy the simulatemap buttom
  observeEvent(input$simulatemap,{
    leafletProxy('map') %>%
      clearImages() %>%
      clearControls() %>%
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
  # output$plotmap <- renderLeaflet({
  #   x1()
  # })
  output$plottrend <- renderPlotly({
    x2()
  })
  
  output$trendinfo <- renderTable({
    x3()
  })
  
  
  
  
  
  
  
  
  
  
  
  
  t1 <- eventReactive(input$clickshare,{
    "一个低分辨率(1000m)的可用于分享的web apps实例如下
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


# shinyApp(ui = ui, server = server)
# rsconnect :: deployApp(PMLshiny)
# rsconnect::appDependencies()