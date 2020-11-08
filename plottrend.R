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
  name <- variable <- inx <- value <- array(dim = c(length(vars_trend), 2019-2013+1, 24,nrow))
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
          as.vector()
        
        variable[i, j-2013+1, k, ] <- vars_trend[i]
        name[i, j-2013+1, k, ] <- table$name
        inx[i, j-2013+1, k, ] <- paste(j, fix_mon(k), fix_day(k), sep = "")
        
        # print(value[i, j-2013+1, k, ])
        # print(variable[i, j-2013+1, k, ])
        # print(name[i, j-2013+1, k, ])
        # print(inx[i, j-2013+1, k, ])
        # 
        # Sys.sleep()
        
        
      }
      nc_close(nc)
    }
  }
  
  
  pdf <- data.table(inx = as_date(as.vector(inx)), 
                    value = as.vector(value), 
                    variable = as.vector(variable), 
                    name = as.vector(name)
  )
  fwrite(pdf, "extract.csv")
  

  
  
  
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
  ofn <- paste("trend.csv", sep = "")
  fwrite(odf, ofn)
  
  
  p <- ggplot(data = pdf,
              aes(inx, value, color = name))+
    geom_point(size = 0.8, alpha = 0.6)+
    # geom_smooth(method = "lm",
    #             se = FALSE
    # )+
    labs(x = "Date", y = "")+
    # scale_x_continuous(breaks = seq(1, 24*7, 12),
    #                    labels = labels
    # )+
    scale_color_brewer(palette='Set1',
                       name = NULL)+
    facet_wrap(.~variable, ncol = 1, scales = "free_y")+
    theme(legend.position = "none",
      axis.title.y = element_text(vjust = 0))
  
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