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

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("北京城区水热通量应用分析程序"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      textAreaInput("dir", 
                    "键入数据库目录", 
                    value = "F:/beijing_urban/data/",
                    rows = 2),
      
      selectInput(inputId = "varname_map",
                  label = "动态地图绘制的数据类型",
                  choices = c("ET", "GPP")),
      
      sliderInput(inputId = "resolution",
                  label = "分辨率",
                  min = 10,
                  max = 100,
                  step = 10,
                  value = 30),
      
      
      # Input: Numeric entry for number of obs to view ----
      dateRangeInput("holiday", "固定站点趋势分析的时间段"),
      
      fluidRow(column(5,
                      numericInput(inputId = "lat",
                                   label = "经度",
                                   value = 120)
      ),
      column(5,
             numericInput(inputId = "lon",
                          label = "纬度",
                          value = 38))
      ),
      
      
      selectInput(inputId = "varname_trend",
                  label = "数据类型",
                  choices = c("ET", "GPP"),
                  multiple = TRUE),
      
      fluidRow(
        actionButton("click", "联系开发者", class = "btn-danger"),
        actionButton("drink", "分享", class = "btn-lg btn-success")
      )
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      leafletOutput(outputId = "plotmap"),
      
      plotlyOutput(outputId = "plottrend")
      
    )
  )
)