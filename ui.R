
navbarPage("北京城区通量数据分析程序", id = "nav",
           
           
           
           
           # TAB 1
           tabPanel("动态地图",
                    
                    #leafletOutput(outputId = "plotmap")
                    
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                        ),
                        
                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = "auto", right = 20, bottom = "auto",
                                      width = 600, height = "auto",
                                      
                                      hr(),
                                      
                                      h4(strong("数据库目录")),
                                      
                                      
                                      textAreaInput("dir", 
                                                    NULL, 
                                                    #value = 'F:/pml_data/',
                                                    value = "data/",
                                                    #value = "F:/PML2.0_NCL_Sentinel_LAI_15D_CASE01/",
                                                    rows = 1),
                                      
                                      h4(strong("参数设置")),
                                      
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
                                      
                                      actionButton("simulatemap", "应用地图绘制", class = "btn-primary"),   
                                      
                                      # abandon resolution
                                      # sliderInput(inputId = "resolution",
                                      #             label = "分辨率 (m) ",
                                      #             min = 10,
                                      #             max = 100,
                                      #             step = 10,
                                      #             value = 10
                                      # ),
                                      
                                      
                                      hr(),
                                      
                                      h4(strong("添加站点信息")),
                                      numericInput(inputId = "dist",
                                                   label = "默认范围 (m)",
                                                   value = 500),
                                      
                                      dataTableOutput("table"),
                                      
                                      actionButton("clearallpoints", "去除所有输入", class = "btn-primary"),
                                      
                                      actionButton("clearlastpoints", "去除上次输入", class = "btn-primary")
                                      
                        ),
                        
                        tags$div(id="cite",
                                 '项目信息: 北京地区高时空分辨率的水热通量数据集构建 
                                 (最终解释权归中国科学院地理与资源研究所所有)'
                        )
                    )
                    
                    
                    
           ),
           
           
           # TAB 2
           tabPanel("站点时间序列分析",
                    
                    # sidebarLayout(sidebarPanel(),
                    #               mainPanel()),
                    
                    sidebarLayout(
                      
                      
                      #=========================================================================
                      # 1. sider bar panel for inputs
                      #=========================================================================
                      
                      sidebarPanel(
                        width = 2,
                        
                        
                        # hr(),
                        # 
                        # h4(strong("站点信息")),
                   
                        selectInput(inputId = "vars_trend",
                                    label = "选择输出的数据",
                                    choices = choices_var[choices_var != "landcover"], #delete land cover
                                    selected = c("ET", "GPP", "Rainf", "LE"),
                                    multiple = TRUE),
                        
                        
                        actionButton("simulatetrend", "应用设置", class = "btn-primary"),
                        
                        # hr(),
                        # 
                        # h4(strong("趋势分析结果")),
                        # 
                        # tableOutput("trendinfo")

                        
                      ),
                      
                      
                      mainPanel(
                        width = 10,
                        
                        # sidebarLayout(
                        #   position = "right",
                        
                        
                        
                        
                        #=========================================================================
                        # 3. main panel for display data
                        #=========================================================================
                        # mainPanel(
                        #   width = 8,
                        #leafletOutput(outputId = "plotmap", height = 600),
                        
                        plotlyOutput(outputId = "plottrend", height = 1000) %>% withSpinner(color="#0dc5c1"),
                        dataTableOutput("table_extract"),
                        dataTableOutput("table_trend")
                        
                        #   ) # end of main panel
                        #   
                        #   
                        #)
                      )

                      
                    )
           ),
           
           # TAB 3
           tabPanel("帮助文档",
                    div(class="outer",
                        
                        includeMarkdown("README.md")
                        # dataTableOutput("table1"),
                        #=========================================================================
                        # 2. sider bar panel for outputs
                        #=========================================================================
                        
                        # sidebarPanel(width = 4,
                        
                        #                   
                        # h4(strong("项目信息")),
                        # 
                        # p("本软件为中国科学院地理与资源研究所受北京市水科院委托而制作，
                        # 供#北京地区高时空分辨率的水热通量数据集构建#项目使用
                        #   其最终解释权归中国科学院地理与资源研究所所有，
                        #   未经允许不得用于其他项目以及商业行为。"),
                        # 
                        # 
                        # h4(strong("注意事项")),
                        # 
                        # p("1.原始数据为10m分辨率，但在内存有限的计算机请选择低分辨率绘图，默认为30m分辨率;
                        # 2.固定站点是在一定半径范围内获取得通量数据。对于区域分析，可选择粗分辨率；对于单点，可以调低至基本覆盖站点测量范围;
                        # 3.数据地理坐标系为WGS1984;
                        #   4. 重新修改应用设置所需时间一般小于1分钟，在修改完成后请点击应用选项完成对应改动。"),
                        # 
                        # 
                        # h4(strong("支持信息")),
                        # 
                        # textOutput("shareinfo"),
                        # 
                        # p(),
                        # 
                        # textOutput("developerinfo"),
                        # 
                        # fluidRow(
                        #   actionButton("clickdeveloper", "联系开发者", class = "btn-danger"),
                        #   actionButton("clickshare", "分享", class = "btn-lg btn-success")
                        # )
                        #                   
                        #                   
                        #      ),
                        
                    )
           )
)
