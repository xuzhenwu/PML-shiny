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

# setings
choices_month <- format(seq.Date(from = as.Date("2013-01-01"), by = "month", length.out = 12*7), "%B-%Y")
choices_var <- c("Ec", "Ei", "Es", "ET", 
                 "GPP", "LAI",
                 "LE", "Rainf",
                 "Rn", "SH",
                 "SWdown", "Tair", "VPD",
                 "landcover")
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
      
      h4(strong("数据库目录")),
      textAreaInput("dir", 
                    NULL, 
                    value = file_location,
                    #value = "data/",
                    #value = "F:/PML2.0_NCL_Sentinel_LAI_15D_CASE01/",
                    rows = 2),
      
      hr(),
      
      h4(strong("通量数据空间分布")),
      
      fluidRow(
        
        column(4,
               selectInput(inputId = "year",
                           label = "年份",
                           choices = 2013:2019,
                           selected = 2019
               )),
        column(4,
               selectInput(inputId = "month",
                           label = "月份",
                           choices = 1:12,
                           selected = 6
               )),
        column(4,
               selectInput(inputId = "submonth",
                           label = "半月",
                           choices = c("上半月", "下半月"),
                           selected = "上半月"
               )),
        
      ),
      
      selectInput(inputId = "varname_map",
                  label = "数据类型",
                  choices = choices_var[choices_var != "Rainf"],
                  selected = "ET"
      ),
      
      sliderInput(inputId = "resolution",
                  label = "分辨率",
                  min = 10,
                  max = 100,
                  step = 10,
                  value = 30
      ),
      
      actionButton("simulatemap", "应用地图绘制参数", class = "btn-primary"),
      
      hr(),
      
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
                  choices = choices_var[choices_var != "landcover"], #delete land cover
                  selected = c("ET", "GPP", "Rainf", "LE"),
                  multiple = TRUE),
      
      
      actionButton("simulatetrend", "应用时间序列参数", class = "btn-primary"),
      
      hr(),
      
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
                     
                     
                     h4(strong("项目信息")),
                     
                     p("本软件为中国科学院地理与资源研究所受北京市水科院委托而制作，
                     供#北京地区高时空分辨率的水热通量数据集构建#项目使用
                       其最终解释权归中国科学院地理与资源研究所所有，
                       未经允许不得用于其他项目以及商业行为。"),
                     
                     
                     h4(strong("注意事项")),
                    
                     p("1.原始数据为10m分辨率，但在内存有限的计算机请选择低分辨率绘图，默认为30m分辨率;
                     2.固定站点是在一定半径范围内获取得通量数据。对于区域分析，可选择粗分辨率；对于单点，可以调低至基本覆盖站点测量范围;
                     3.数据地理坐标系为WGS1984;
                       4. 重新修改应用设置所需时间一般小于1分钟，在修改完成后请点击应用选项完成对应改动。"),
                     
                     
                     h4(strong("支持信息")),
                     
                     textOutput("shareinfo"),
                     
                     p(),
                     
                     textOutput("developerinfo"),
                     
                     fluidRow(
                       actionButton("clickdeveloper", "联系开发者", class = "btn-danger"),
                       actionButton("clickshare", "分享", class = "btn-lg btn-success")
                     )
                     
                     
        ),
        
        #=========================================================================
        # 3. main panel for display data
        #=========================================================================
        mainPanel(
          # width = 8,
          leafletOutput(outputId = "plotmap", height = 450),
          
          plotlyOutput(outputId = "plottrend", height = 600)
          
        ) # end of main panel
        
        
      )
    )
  )
)
