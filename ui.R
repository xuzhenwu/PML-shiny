slibrary <- function(fun){
  fun_name <- as.character(substitute(fun))
  if(is.element(fun_name, installed.packages()[,1]) == FALSE)
    install.packages(fun_name)
  COMMAND <- paste("library(", fun_name, ")", sep = "")
  eval(parse(text = COMMAND))
}

# dependences 
slibrary(shiny)
slibrary(leaflet)
slibrary(raster)
slibrary(rgdal)
slibrary(leaflet)
slibrary(RColorBrewer)
slibrary(reshape2)
slibrary(plotly)
slibrary(gapminder)
slibrary(ggplot2)
slibrary(rsconnect)
slibrary(shinyFiles)
slibrary(shinyWidgets)
slibrary(exactextractr)
slibrary(data.table)
slibrary(sf)
slibrary(ncdf4)
slibrary(stringr)

choices_month <- format(seq.Date(from = as.Date("2013-01-01"), by = "month", length.out = 12*7), "%B-%Y")
choices_var <- c("Ec", "Es", "ET", "GPP", "landcover",
                 "LE", "Rainf", "SWdown", "Tair", "VPD")
months <- c(paste("0", 1:9, sep = ""), 10:12)
file_location <- "F:/pml_data/"

ui <- fluidPage(
  
  
  titlePanel(strong("北京城区通量数据分析程序")),
  # sidebarLayout(sidebarPanel(),
  #               mainPanel()),
  
  sidebarLayout(
    
    
    #=========================================================================
    # 1. sider bar panel for inputs
    #=========================================================================
    
    sidebarPanel(
      width = 3,
      
      h4(strong("键入数据库目录")),
      textAreaInput("dir", 
                    NULL, 
                    value = file_location,
                    #value = "data/",
                    #value = "F:/PML2.0_NCL_Sentinel_LAI_15D_CASE01/",
                    rows = 2),
      
      
      h4(strong("查看通量分布信息")),
      fluidRow(
        
        column(4,
               selectInput(inputId = "year",
                           label = "年份",
                           choices = 2013:2019,
                           selected = 2013
               )),
        column(4,
               selectInput(inputId = "month",
                           label = "月份",
                           choices = months,
                           selected = "06"
               )),
        column(4,
               selectInput(inputId = "submonth",
                           label = "半月",
                           choices = c("a", "b"),
                           selected = "a"
               )),
        
      ),
      
      selectInput(inputId = "varname_map",
                  label = "数据类型",
                  choices = choices_var,
                  selected = "ET"
                  ),
      
      sliderInput(inputId = "resolution",
                  label = "分辨率",
                  min = 10,
                  max = 100,
                  step = 10,
                  value = 30
                  ),
      

      h4(strong("固定站点时间序列分析")),
      
      # sliderTextInput(
      #   inputId    = "date_range",
      #   label      = "时间区间",
      #   choices    = choices_month,
      #   animate    = T,
      #   selected   = c(min(choices_month), max(choices_month)),
      #   grid       = F,
      #   width      = "100%"
      # ),
      
      
      fluidRow(column(4,
                      numericInput(inputId = "lon",
                                   label = "经度",
                                   value = 116.379168)),
               column(4,
                      numericInput(inputId = "lat",
                                   label = "纬度",
                                   value = 40.001501)),
               column(4,
                      numericInput(inputId = "dist",
                                   label = "范围",
                                   value = 500))
      ),
      
      
      selectInput(inputId = "vars_trend",
                  label = "数据类型",
                  choices = choices_var,
                  selected = c("ET", "GPP", "LAI", "Es", "Eca"),
                  multiple = TRUE),
      
      h4(strong("趋势分析结果")),
      
      tableOutput("trendinfo"),
      
    ),
    
    
    mainPanel(
      width = 9,
      
      sidebarLayout(
        position = "right",
        
        
        #=========================================================================
        # 2. sider bar panel for outputs
        #=========================================================================
        
        sidebarPanel(width = 4,
                     
                     
                     h4(strong("项目支持")),
                     
                     p("北京地区高时空分辨率的地表水热通量数据集构建"),
     
                     h4(strong("注意事项")),
                     
                     p("1.在内存有限的计算机请选择低分辨率绘图"),
                     p("2.重新修改设置最大需要1分钟运算时间"),
                     
                     
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
          leafletOutput(outputId = "plotmap", height = 450),
          
          # plotlyOutput(outputId = "plottrend", height = 600)
          
        ) # end of main panel
        
        
      )
    )
  )
)
