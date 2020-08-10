plottrend <- function(dir,
                      vars_trend,
                      lat,
                      lon,
                      dist
                      ){
  
  
  # test input
  # dir <- "F:/pml_dataset/"
  # vars_trend <- c("GPP", "ET")
  # lat <- 40.001501  # 地理所
  # lon <- 116.379168
  # dist <- 500 #meter
  
  #==========================================================================
  # set ploygon 
  # double transform for getting a meter-based circle
  #==========================================================================
  st_point <- st_point(c(lon, lat))%>% 
    st_sfc(crs = 4326) %>%  # WGS 1984
    st_transform(crs = 2436) # Beijing 1954 / Gauss-Kruger CM 117E
  st_circle <- st_buffer(st_point, dist = dist, nQuadSegs = 30) %>%
    st_transform(crs = 4326)
  

  # file names
  fl <- dir(dir, "*.nc", full.names = TRUE)
  fl_name <- str_match(fl,"A......._B")%>%
    str_sub(start = 1, end = 8)
  # extract vars
  extract_all <- function(j, fl, st_circle, vars_trend){
    extract_single <- function(i, fn, st_circle, vars_trend){
      value <- raster(fn, varname = vars_trend[i])%>%
        exact_extract(st_circle, "mean")
    }
    res <- lapply(seq_along(vars_trend), extract_single, fl[j], st_circle, vars_trend)
    names(res) <- vars_trend
    return(res)
  }
  system.time({
    res <- lapply(seq_along(fl), extract_all, fl, st_circle, vars_trend)
  })
  names(res) <- fl_name
  # change format
  df <- matrix(ncol = length(vars_trend),
              nrow = length(res)
              )
  inx <- 0
  for(i in 1:length(res))
    for(j in 1:length(vars_trend)){
      df[i, j] <- res[[i]][[j]] 
      inx[i] <- i
    }
  df <- as.data.frame(df)
  names(df) <- vars_trend
  df <- cbind(df, inx)
  pdf <- melt(df, id.vars = "inx")
  
  
  labels1 <- paste(2013:2019, 1, sep = "-")
  labels2 <- paste(2013:2019, 6, sep = "-")
  inx <- 1
  labels <- ""
  for(i in seq_along(labels1)){
    labels[inx] <- labels1[i] 
    labels[inx + 1] <- labels2[i] 
    inx <- inx + 2 
  }
  
  # write lm result
  ave <- pvalue <- r2 <- trend_value <- 0
  variable <- ""
  dt <- as.data.table(df)
  for(i in seq_along(vars_trend)){
    dt <- as.data.table(pdf)
    adt <- dt[variable %in% vars_trend[i],]
    lm_model <- lm(value~inx, adt)
    lm_sum <- summary(lm_model)
    
    variable[i] <- vars_trend[i]
    ave[i] <- mean(adt$value)%>%round(3)
    pvalue[i]  <- lm_sum[["coefficients"]][2,4]%>%round(3)
    r2[i]  <- lm_sum[["r.squared"]]%>%round(3)
    trend_value[i]  <- (lm_sum[["coefficients"]][2,1]*24)%>%round(3) #modify for inx
  }
  odf <- data.table(variable, ave, trend_value, pvalue)
  ofn <- paste(dir, "trend_info.csv")
  fwrite(odf, ofn)
  
  
  p <- ggplot(data = pdf,
              aes(inx, value, color = variable))+
    geom_point()+
    geom_smooth(method = "lm",
                color = "red",
                se = FALSE
    )+
    labs(x = "Date", y = "Value")+
    scale_x_continuous(breaks = seq(1, 24*7, 12),
                      labels = labels
                      )+
    scale_color_brewer(palette='Set1',
                       name = "Variables")+
    facet_wrap(.~variable, ncol = 1, scales = "free_y")+
    theme(legend.position = "none")
  
  p <- ggplotly(p)
  
  
  return(p)
  #end of trendplot
}