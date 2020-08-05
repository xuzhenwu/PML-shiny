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


ui <- fluidPage(
  
 
  titlePanel("北京城区水热通量应用分析程序"),
  # sidebarLayout(sidebarPanel(),
  #               mainPanel()),
                
  sidebarLayout(
    
    
    #=========================================================================
    # 1. sider bar panel for inputs
    #=========================================================================
    
    sidebarPanel(
      width = 3,
      
      textAreaInput("dir", 
                    "键入数据库目录", 
                    value = "data/",
                    rows = 2),
      
      selectInput(inputId = "varname_map",
                  label = "动态地图绘制的数据类型",
                  choices = c("ET", "GPP")),
      
      sliderInput(inputId = "resolution",
                  label = "分辨率",
                  min = 10,
                  max = 100,
                  step = 10,
                  value = 50),
      
      dateRangeInput("holiday", "固定站点趋势分析的时间段"),
      
      fluidRow(column(6,
                      numericInput(inputId = "lon",
                                   label = "经度",
                                   value = 120)),
               column(6,
                      numericInput(inputId = "lat",
                                   label = "纬度",
                                   value = 38))
      ),
      
      
      selectInput(inputId = "varname_trend",
                  label = "数据类型",
                  choices = c("ET", "GPP"),
                  multiple = TRUE)
      
    ),
    

    mainPanel(
      width = 9,
      
      sidebarLayout(
        position = "right",
        
        
        #=========================================================================
        # 2. sider bar panel for outputs
        #=========================================================================
        
        sidebarPanel(width = 4,
                     
                     fluidRow(
                       actionButton("click", "联系开发者", class = "btn-danger"),
                       actionButton("drink", "分享", class = "btn-lg btn-success")
                     )
                     
        ),
        
        #=========================================================================
        # 3. main panel for display data
        #=========================================================================
        mainPanel(
          width = 8,
          leafletOutput(outputId = "plotmap"),
          
          plotlyOutput(outputId = "plottrend")
          
        ) # end of main panel
        
        
      )
    )
  )
)
