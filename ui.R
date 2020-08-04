library(shiny)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("北京城区水热通量应用分析程序"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      sliderInput(inputId = "bins",
                  label = "Number of bins:",
                  min = 1,
                  max = 50,
                  value = 30),
      
      selectInput(inputId = "varname_map",
                  label = "动态地图绘制的数据类型",
                  choices = c("ET", "GPP")),
      
      
      # Input: Numeric entry for number of obs to view ----
      dateRangeInput("holiday", "固定站点趋势分析的时间段"),
      
      numericInput(inputId = "lat",
                   label = "经度",
                   value = 120),
      
      numericInput(inputId = "lon",
                   label = "纬度",
                   value = 38),
      
      selectInput(inputId = "varname_trend",
                  label = "数据类型",
                  choices = c("ET", "GPP"),
                  multiple = TRUE)
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      leafletOutput(outputId = "plotmap"),
      
      plotlyOutput(outputId = "plottrend")
      
    )
  )
)