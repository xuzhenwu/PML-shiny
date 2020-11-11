

  # debug option
  dir <- "data/"
  vars_trend <- c("GPP", "ET", "LAI", "Tair", "Rainf")

  table <- list
  st_circle <- read_sf("project/7sites.shp")%>%
    st_transform(4326)
  loca_name <- st_circle$NAME
  nrow <- length(loca_name)
  

  
  # funcs for pasrse k in a year: 1-24
  fix_mon <- function(k){
    x <- floor((k-1)/2)+1
    if(x >= 10)
      return(as.character(x))
    else 
      return(paste0(0, x))
  }
  fix_day <- function(k){
    if(k%%2 == 0)
      return("15")
    else
      return("01")
  }
  
  # extract_data
  inx <- name <- variable <- date <- value <- array(dim = c(length(vars_trend), 2019-2013+1, 24,nrow))
  for(i in seq_along(vars_trend)){
    # year
    for(j in 2013:2019){
      fn <- dir(dir,
                paste(vars_trend[i], ".*", j, ".*nc", sep = ""), 
                full.names = TRUE)
      nc <- nc_open(fn)
      # tiles
      for(k in 1:24){

        
        value[i, j-2013+1, k, ] <- raster(fn, band = k)%>%
          exact_extract(st_circle, "mean") %>%
          as.vector() %>%
          round(6)
        
        variable[i, j-2013+1, k, ] <- vars_trend[i]
        name[i, j-2013+1, k, ] <- loca_name
        date[i, j-2013+1, k, ] <- paste(j, fix_mon(k), fix_day(k), sep = "")
        inx[i, j-2013+1, k, ] <- k + (j-2013)*24

      }
      nc_close(nc)
    }
  }
  # export extracted data
  pdf <- data.table(
    name = as.vector(as.character(name)),
    variable = as.vector(as.character(variable)), 
    date = as_date(as.vector(date)), 
    value = as.vector(value)
  )
  write.csv(pdf, "extract.csv", col.names = FALSE)
  
  
  # print(pdf)
  # print(table)
  
  # calculate trend
  dt <- cbind(pdf, inx = as.vector(inx))
  name <- NULL
  variable <- ave <- pvalue <- r2 <- trend_value <- name <- matrix(nrow = length(vars_trend), ncol = length(loca_name))
  for(i in seq_along(vars_trend))
    for(j in seq_along(loca_name)){
      
      adt <- dt[variable == vars_trend[i] & name == loca_name[j],]
      lm_model <- lm(value~inx, adt) # 24 inx in a year
      lm_sum <- summary(lm_model)
      
      name[i, j] <- loca_name[j]
      variable[i, j] <- vars_trend[i]
      ave[i, j] <- mean(adt$value)%>%round(3)
      pvalue[i, j]  <- lm_sum[["coefficients"]][2,4]%>%round(3)
      r2[i, j]  <- lm_sum[["r.squared"]]%>%round(3)
      trend_value[i, j]  <- (lm_sum[["coefficients"]][2,1]*24)%>%round(3) # modify for date
      
    }
  odf <- data.table(
    name = name %>% as.vector(),
    variable = variable %>% as.vector(),
    ave = ave %>% as.vector(),
    trend_value = trend_value %>% as.vector(),
    pvalue = pvalue %>% as.vector(),
    r2 = r2 %>% as.vector()
  )
  ofn <- paste("trend.csv", sep = "")
  write.csv(odf, ofn)
  
  
  # match units
  for(i in seq_along(vars_trend)){
    if(i == 1)
      units_trend <- dt_varunit[variables == vars_trend[i],]$units[1]
    else
      units_trend <- c(units_trend, dt_varunit[variables == vars_trend[i],]$units[1])
  }
  str_labels <- paste0(vars_trend, " (", units_trend, ") ")
  
  
  pdf$variable <- factor(pdf$variable, level = vars_trend, labels = str_labels)
  
  
  # ggplot
  p <- ggplot(data = pdf,
              aes(date, value, color = name))+
    geom_point(size = 1.2, alpha = 0.8)+
    # geom_smooth(method = "lm",
    #             se = FALSE
    # )+
    labs(x = "日期", y = "变量值")+
    scale_x_continuous(breaks = as_date(paste0(2013:2020, "-01-01"))
    )+
    scale_color_manual(values = rev(brewer.pal(length(levels(factor(pdf$name))), "Set1")),
                       name = NULL)+
    facet_wrap(.~variable, ncol = 1, scales = "free_y", labeller = labeller(str_labels))+
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 12),
      legend.background = element_rect(fill = "white", size = 4, colour = "white"),
      legend.justification = c(0, 1),
      legend.position = c(0, 1),
      axis.ticks = element_line(colour = "grey70", size = 0.2),
      panel.grid.major = element_line(colour = "grey70", size = 0.2),
      panel.grid.minor = element_blank()
    )


  p <- ggplotly(p)%>%
    layout(
      legend = list(orientation = "h",
                    x = 0,
                    y = 1),
      height = 1000
    )
  
  print(p)
