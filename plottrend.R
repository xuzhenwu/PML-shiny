plottrend <- function(dir,
                      vars_trend,
                      lat,
                      lon,
                      dist
){
  
  
  # dir <- "F:/pml_data/1500/"
  # vars_trend <- c("GPP", "ET")
  # lat <- 40.001501  # 地理所
  # lon <- 116.379168
  # dist <- 1500 #meter
  
  #==========================================================================
  # set ploygon 
  # double transform for getting a meter-based circle
  #==========================================================================
  st_point <- st_point(c(lon, lat))%>% 
    st_sfc(crs = 4326) %>%  # WGS 1984
    st_transform(crs = 2436) # Beijing 1954 / Gauss-Kruger CM 117E
  st_circle <- st_buffer(st_point, dist = dist, nQuadSegs = 120) %>%
    st_transform(crs = 4326)
  
  
  # extract info
  fl <- dir(dir,
            paste("*.nc", sep = ""), 
            full.names = TRUE)
  fn <- fl[1]
  nc <- nc_open(fn)
  PI <- 3.1415926
  lon_start <- lon - dist/((111*10^3)*cos(lat/360*2*PI)) * 2
  lon_end <- lon + dist/((111*10^3)*cos(lat/360*2*PI)) * 2
  lat_start <- lat + dist/((111*10^3)) * 2
  lat_end <- lat - dist/((111*10^3)) * 2
  er <- (nc$dim$lon$vals - lon_start)^2
  ilon_start <- which.min(er)
  er <- (nc$dim$lon$vals - lon_end)^2
  ilon_end <- which.min(er)
  er <- (nc$dim$lat$vals - lat_start)^2
  ilat_start <- which.min(er)
  er <- (nc$dim$lat$vals - lat_end)^2
  ilat_end <- which.min(er)
  start <- c(ilon_start, ilat_start)
  count <- c(ilon_end - ilon_start, ilat_end - ilat_start)
  nc_close(nc)
  
  
  # vars
  ii <- 1
  inx <- value <- 1
  variable <- ""
  for(i in seq_along(vars_trend)){
    # year
    for(j in 2013:2019){
      fn <- dir(dir,
                paste(vars_trend[i], ".*", j, ".*nc", sep = ""), 
                full.names = TRUE)
      nc <- nc_open(fn)
      # tiles
      for(k in 1:24){
        data <- ncvar_get(nc, 
                          varid = vars_trend[i], 
                          c(start, k), 
                          c(count, 1)
                          )
        
        value[ii] <- raster(data, 
                            xmn = lon_start, 
                            xmx = lon_end, 
                            ymn = lat_end, 
                            ymx = lat_start,
                            crs = "+proj=longlat +datum=WGS84")%>%
          exact_extract(st_circle, "mean")
        variable[ii] <- vars_trend[i]
        inx[ii] <- k + (j - 2013)*24
        ii <- ii + 1
      }
      nc_close(nc)
    }
  }
  
  pdf <- data.frame(inx = inx, 
                    value = value, 
                    variable = variable
                    )
    
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
  dt <- as.data.table(pdf)
  for(i in seq_along(vars_trend)){
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
  ofn <- paste(dir, "trend_info.csv", sep = "")
  fwrite(odf, ofn)
  
  
  p <- ggplot(data = pdf,
              aes(inx, value, color = variable))+
    geom_point()+
    geom_smooth(method = "lm",
                color = "red",
                se = FALSE
    )+
    labs(x = "Date", y = "")+
    scale_x_continuous(breaks = seq(1, 24*7, 12),
                       labels = labels
    )+
    scale_color_brewer(palette='Set1',
                       name = "Variables")+
    facet_wrap(.~variable, ncol = 1, scales = "free_y")+
    theme(legend.position = "none",
          axis.title.y = element_text(vjust = 0)
          )
  
  p <- ggplotly(p)
  
  
  
  return(p)
  #end of trendplot
}


# 
# 
# r <- raster(data, xmn = lon_start, xmx = lon_end, ymn = lat_end, ymx = lat_start)
# value <-exact_extract(r, st_circle, "mean")
# 
# # extract vars
# extract_all <- function(j, fl, st_circle, vars_trend){
#   
#   # file names
#   fl <- dir(dir,
#             paste(vars_trend[i], ".*.nc", sep = ""), 
#             full.names = TRUE)
#   
#   extract_single <- function(i, fl, st_circle, vars_trend){
#     
#     nc <- nc_open(fn)
#     data <- ncvar_get(nc, 
#                       varid = vars_trend[i], 
#                       start, 
#                       count)
#     r <- raster(fn, band = 1)
#     value <-exact_extract(r, st_circle, "mean")
#     
#     year <- year
#   }
#   res <- lapply(seq_along(vars_trend), extract_single, fl, st_circle, vars_trend)
#   
#   names(res) <- vars_trend
#   return(res)
# }
# system.time({
#   res <- lapply(seq_along(fl), extract_all, fl, st_circle, vars_trend)
# })
# names(res) <- fl_name
# change format
# df <- matrix(ncol = length(vars_trend),
#              nrow = length(res)
# )
# inx <- 0
# for(i in 1:length(res))
#   for(j in 1:length(vars_trend)){
#     df[i, j] <- res[[i]][[j]] 
#     inx[i] <- i
#   }
# df <- as.data.frame(df)
# names(df) <- vars_trend
# df <- cbind(df, inx)
# pdf <- melt(df, id.vars = "inx")