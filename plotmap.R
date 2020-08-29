plotmap <- function(  
  dir,
  varname,
  resolution,
  year,
  month,
  submonth,
  lat,
  lon,
  dist){
  
  # dir <- "data/"
  # varname = "SH"
  # resolution = 10
  # year  = 2013
  # month = 6
  # submonth = "a"
  # lat = 40.001501
  # lon = 116.379168
  # dist = 500

  
  fn <- dir(dir, 
            paste(varname, ".*", year, sep = "")
            , full.names = TRUE)
    
  # palette
  palette <- c("Spectral", "YlGn")
  pals <- palette[1]
  if(varname == "GPP"|
     varname == "LAI")
    pals <- palette[2]
  pals <- brewer.pal(9, pals)
  
  
  #==================================here
  # compute layer
  layer <- 1
  if(str_detect(submonth, "上半月"))
    layer <- 2
  layer <- (as.numeric(month) - 1)*2 + layer
  
  # modify for landcover
  if(varname == "landcover"){
    layer <- 1
    fn <- dir(dir, 
              paste(varname, sep = "")
              , full.names = TRUE)
    
  }
  # read raster file and aggreagate
  r <- raster(fn, band = layer)
  
  
  aggregate_inx <- ceiling(as.numeric(resolution) / 10)
  r <- aggregate(r, fact = aggregate_inx, fun = mean)
  
  pal <- colorNumeric(pals, values(r),
                      na.color = "transparent")
  
  # set ploygon
  st_point <- st_point(c(lon, lat))%>% 
    st_sfc(crs = 4326) %>%  # WGS 1984
    st_transform(crs = 2436) # Beijing 1954 / Gauss-Kruger CM 117E
  st_circle <- st_buffer(st_point, dist = dist, nQuadSegs = 120) %>%
    st_transform(crs = 4326)
  
  # leaflet
  p <- leaflet() %>% addTiles() %>%
    addRasterImage(r, colors = pal, opacity = 0.85,
                   maxBytes = Inf) %>%
    addPolygons(data = st_circle, color = "blue")%>%
    addLegend(pal = pal, values = values(r),
              title = "Value")
  
  return(p)
}