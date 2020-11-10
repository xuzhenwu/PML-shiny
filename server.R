# Define server 
server <- function(input, output, session) {
  
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
      
      # st <- st_point(c(click$lng, click$lat))%>% 
      #   st_as_sf(coords = c("lng", "lat")) %>% 
      #   st_set_crs(3857)
      # 
      # print(st)
      # st <- st_transform(st, crs = 4326)
      # print(st)
      
      newLine <- isolate(data.table(name = paste0("未命名站点", nrow(values$table) + 1), lng = round(click$lng, 6), lat = round(click$lat, 6), dist = input$dist))
      print(newLine)
      isolate(values$table <- rbind(values$table, newLine))
    }
    
  })
  
  output$table <- renderDataTable({
    values$table
    },
                                  options = list(
                                    paging = TRUE,
                                    searching = TRUE,
                                    fixedColumns = TRUE,
                                    autoWidth = TRUE,
                                    ordering = TRUE,
                                    dom = 'Bfrtip',
                                    buttons = list(
                                      list(extend = "csv", text = '<span class="glyphicon glyphicon-download-alt"></span> csv'),
                                      list(extend = "excel", text = '<span class="glyphicon glyphicon-download"></span> excel')
                                    )
                                  ),
                                  selection = 'none',
                                  editable = TRUE,
                                  rownames = TRUE,
                                  extensions = 'Buttons',
                                  class = "display"
  )
  observeEvent(input$table_cell_edit, {

      values$table[input$table_cell_edit$row,input$table_cell_edit$col] <- as.character(input$table_cell_edit$value)
    
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
      
      
      
      labs <- lapply(seq(nrow(values$table)), function(i) {
        paste0( '<p>', "站点名: ",  values$table[i, "name"], '<p></p>', 
                '<p>', "经度: ",  values$table[i, "lng"], '<p></p>',
                '<p>', "纬度: ",  values$table[i, "lat"], '<p></p>',
                '<p>', "半径范围: ",  values$table[i, "dist"], '<p></p>') 
      })
      
      leafletProxy('map')%>%
        addPolylines(data = st_circle, color = "black",
                     weight = 1.5,
                     opacity = 0.8, fillOpacity = 0.2)%>%
        addMarkers(lng = values$table$lng, 
                   lat = values$table$lat, 
                   label = lapply(labs, htmltools::HTML))
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
    values$table <- data.table(name = character(), lng = numeric(), lat = numeric(), dist = numeric())
    
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
      values$table <- data.table(name = character(), lng = numeric(), lat = numeric(), dist = numeric())
    update_marker()
    
  })
  
  
  
  # add raster map by deploy the simulatemap buttom
  observeEvent(input$simulatemap,{
    withProgress(message = '正在加载地图...', value = 50, {
      leafletProxy('map') %>%
        clearImages() %>%
        clearControls() %>%
        plotmap(input$dir,
                input$varname_map,
                input$resolution,
                input$year,
                input$month,
                input$submonth)
    })
    
  })
  
  
  
  
  observeEvent(input$simulatetrend,{
    
    updateTabsetPanel(session, inputId = "T2", selected = "T2A1")
    
    
    
    output$plottrend <- renderPlotly({
      withProgress(message = '正在处理数据...', value = 50, {
        plottrend(isolate(input$dir),
                  isolate(input$vars_trend),
                  isolate(values$table)
        )
      })
    })
    
    # Sys.sleep(5)
    
    
    output$table_extract <- renderDataTable(
      {
        table_extract <- fread("extract.csv")
        names(table_extract) <- c("站点名称", "变量", "日期", "值")
        table_extract
      },
      options = list(
        paging = TRUE,
        searching = TRUE,
        fixedColumns = TRUE,
        autoWidth = TRUE,
        ordering = TRUE,
        dom = 'Bfrtip',
        buttons = list(
          list(extend = "csv", text = '<span class="glyphicon glyphicon-download-alt"></span> csv'),
          list(extend = "excel", text = '<span class="glyphicon glyphicon-download"></span> excel')
        )
      ),
      selection = 'none',
      editable = TRUE,
      rownames = TRUE,
      extensions = 'Buttons',
      class = "display"
    )
    
    
    output$table_trend <- renderDataTable(
      {
        table_trend <- fread("trend.csv")
        names(table_trend) <- c("站点名称", "变量", "均值", "趋势值(单位/年)", "P值", "R2")
        table_trend 
      },
      options = list(
        paging = TRUE,
        searching = TRUE,
        fixedColumns = TRUE,
        autoWidth = TRUE,
        ordering = TRUE,
        dom = 'Bfrtip',
        buttons = list( 
          list(extend = "csv", text = '<span class="glyphicon glyphicon-download-alt"></span> csv'),
          list(extend = "excel", text = '<span class="glyphicon glyphicon-download"></span> excel')
        )
      ),
      selection = 'none',
      editable = TRUE,
      rownames = TRUE,
      extensions = 'Buttons',
      class = "display"
      )
    
  })
 
  
  # 
  # t1 <- eventReactive(input$clickshare,{
  #   "一个低分辨率(1000m)的可用于分享的web apps实例如下
  #   https://xuzhenwu.shinyapps.io/PML-shiny/ \n "
  # })
  # 
  # t2 <- eventReactive(input$clickdeveloper,{
  #   "如有疑问，可经15521242747联系项目程序开发人员\n  "
  # })
  # 
  # output$shareinfo <- renderText(
  #   t1()
  # )
  # 
  # output$developerinfo  <- renderText(
  #   t2()
  # )
  
  
  
}


# shinyApp(ui = ui, server = server)
# rsconnect :: deployApp(PMLshiny)
# rsconnect::appDependencies()