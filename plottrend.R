plottrend <- function(dir,
                      vars_trend,
                      table
){
  
  
  # dir <- "F:/pml_data/1500/"
  # vars_trend <- c("GPP", "ET")
  # lat <- 40.001501  # 地理所
  # lon <- 116.379168
  # dist <- 1500 #meter

  dist <- table$dist[1]
  name <- table$name[1]
  
  nrow <- nrow(table)
  
  #==========================================================================
  # set ploygon 
  # double transform for getting a meter-based circle
  #==========================================================================
  sf_point <- st_as_sf(table, coords = c("lng", "lat")) %>% 
    st_set_crs(4326)%>% 
    st_transform(crs = 2436)
  st_circle <- st_buffer(sf_point, table$dist)%>% 
    st_transform(crs = 4326)
  
  
  
  
  # extract the extent to reduce time of reading
  fl <- dir(dir,
            paste("*.nc", sep = ""), 
            full.names = TRUE)
  # fn <- fl[1]
  # nc <- nc_open(fn)
  # PI <- 3.1415926
  # lon_start <- lat_start <- lon_end <- lat_end <- 0
  # ilon_start <- ilat_start <- ilon_end <- ilat_end <- 0
  # for(i in 1:nrow){
  #   
  #   lon <- table$lng[i]
  #   lat <- table$lat[i]
  #   dist < - table$dist[i]
  #   
  #   lon_start[i] <- lon - dist/((111*10^3)*cos(lat/360*2*PI)) * 2
  #   lon_end[i] <- lon + dist/((111*10^3)*cos(lat/360*2*PI)) * 2
  #   lat_start[i] <- lat + dist/((111*10^3)) * 2
  #   lat_end[i] <- lat - dist/((111*10^3)) * 2
  #   er <- (nc$dim$lon$vals - lon_start[i])^2
  #   ilon_start[i] <- which.min(er)
  #   er <- (nc$dim$lon$vals - lon_end[i])^2
  #   ilon_end[i] <- which.min(er)
  #   er <- (nc$dim$lat$vals - lat_start[i])^2
  #   ilat_start[i] <- which.min(er)
  #   er <- (nc$dim$lat$vals - lat_end[i])^2
  #   ilat_end[i] <- which.min(er)
  # 
  # }
  # start <- c(min(ilon_start), min(ilat_start))
  # count <- c(max(ilon_end) - min(ilon_start), max(ilat_end)- min(ilat_start))
  # lon_start <- min(lon_start)
  # lat_end <- min(lat_end)
  # lon_end <- max(lon_end) 
  # lat_start <- max(lat_start)
  # 
  # nc_close(nc)
  
  # funcs
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
  
  
  # vars
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
        # data <- ncvar_get(nc, 
        #                   varid = vars_trend[i], 
        #                   c(start, k), 
        #                   c(count, 1)
        # )
        
        # value[i, j-2013+1, k, ] <- raster(data, 
        #                        xmn = lon_start, 
        #                        xmx = lon_end, 
        #                        ymn = lat_end, 
        #                        ymx = lat_start,
        #                        crs = "+proj=longlat +datum=WGS84")%>%
        #   exact_extract(st_circle, "mean") %>%
        #   as.vector()
        
        value[i, j-2013+1, k, ] <- raster(fn, band = k)%>%
          exact_extract(st_circle, "mean") %>%
          as.vector() %>%
          round(6)
        
        variable[i, j-2013+1, k, ] <- vars_trend[i]
        name[i, j-2013+1, k, ] <- table$name
        date[i, j-2013+1, k, ] <- paste(j, fix_mon(k), fix_day(k), sep = "")
        inx[i, j-2013+1, k, ] <- k + (j-2013)*24
        # print(value[i, j-2013+1, k, ])
        # print(variable[i, j-2013+1, k, ])
        # print(name[i, j-2013+1, k, ])
        # print(date[i, j-2013+1, k, ])
        # 
        # Sys.sleep()
        
        
      }
      nc_close(nc)
    }
    
    
    
    
  }
  
  # export extracted data
  pdf <- data.table(
    name = as.vector(name),
    variable = as.vector(variable), 
    date = as_date(as.vector(date)), 
    value = as.vector(value)
  )
  fwrite(pdf, "extract.csv")
  
  # calculate trend
  dt <- cbind(pdf, inx = as.vector(inx))
  name <- NULL
  variable <- ave <- pvalue <- r2 <- trend_value <- name <- matrix(nrow = length(vars_trend), ncol = length(table$name))
  print("s1")
  for(i in seq_along(vars_trend))
    for(j in seq_along(table$name)){
      
    adt <- dt[variable == vars_trend[i] & name == table$name[j],]
    lm_model <- lm(value~inx, adt) # 24 inx in a year
    lm_sum <- summary(lm_model)
    
    name[i, j] <- table$name[j]
    variable[i, j] <- vars_trend[i]
    ave[i, j] <- mean(adt$value)%>%round(3)
    pvalue[i, j]  <- lm_sum[["coefficients"]][2,4]%>%round(3)
    r2[i, j]  <- lm_sum[["r.squared"]]%>%round(3)
    trend_value[i, j]  <- (lm_sum[["coefficients"]][2,1]*24)%>%round(3) # modify for date

    }
  print("s2")
  odf <- data.table(
    name = name %>% as.vector(),
    variable = variable %>% as.vector(),
    ave = ave %>% as.vector(),
    trend_value = trend_value %>% as.vector(),
    pvalue = pvalue %>% as.vector(),
    r2 = r2 %>% as.vector()
    )
  ofn <- paste("trend.csv", sep = "")
  fwrite(odf, ofn)
  print("s3")
  
  
  p <- ggplot(data = pdf,
              aes(date, value, color = name))+
    geom_point(size = 1.2, alpha = 0.8)+
    # geom_smooth(method = "lm",
    #             se = FALSE
    # )+
    labs(x = "日期", y = "变量值")+
    scale_x_continuous(breaks = as_date(paste0(2013:2020, "-01-01"))
    )+
    scale_color_manual(values = rev(brewer.pal(length(levels(factor(name))), "Set1")),
                       name = NULL)+
    facet_wrap(.~variable, ncol = 1, scales = "free_y")+
    theme_bw() +
    theme(
      plot.title = element_text(face = "bold", size = 12),
      #legend.background = element_rect(fill = "white", size = 4, colour = "white"),
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
# date <- 0
# for(i in 1:length(res))
#   for(j in 1:length(vars_trend)){
#     df[i, j] <- res[[i]][[j]] 
#     date[i] <- i
#   }
# df <- as.data.frame(df)
# names(df) <- vars_trend
# df <- cbind(df, date)
# pdf <- melt(df, id.vars = "date")