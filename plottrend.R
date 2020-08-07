plottrend <- function(dir,
                      vars_trend,
                      lat,
                      lon,
                      dist
                      ){
  
  
  # test input
  #dir <- "F:/dataset_pml/"
  #vars_trend <- c("GPP", "ET")
  #lat <- 40.001501  # 地理所
  #lon <- 116.379168
  #dist <- 500 #meter
  
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
  
  
  p <- ggplot(data = pdf,
              aes(inx, value, color = variable))+
    geom_point()+
    geom_smooth(method = "lm",
                color = "red",
                se = FALSE
    )+
    labs(x = "Date", y = "Value")+
    scale_color_brewer(palette='Set1',
                       name = "Variables")+
    facet_wrap(.~variable, ncol = 1, scales = "free_y")+
    theme(legend.position = "none")
  
  p1 <- ggplotly(p)
  
  return(p1)
  #end of trendplot
}