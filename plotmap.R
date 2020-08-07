

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
  
  #dir <- "F:/dataset_pml/"
  #varname = "ET"
  #resolution = 50
  #year  = 2013
  #month = 6
  #submonth = "a"
  #lat = 40.001501
  #lon = 116.379168
  #dist = 500

  
  # match file
  fn_prefix <- paste(year, month, submonth, "_", sep = "")
  fn <- dir(dir, 
            paste("*", fn_prefix, "*",sep = "")
            , full.names = TRUE)
  
  # palette
  palette <- c("Spectral", "YlGn")
  pals <- palette[1]
  if(varname == "GPP")
    pals <- palette[2]
  pals <- brewer.pal(9, pals)
  
  # read raster file and aggreagate
  r <- raster(fn, varname = varname)
  aggregate_inx <- ceiling(as.numeric(resolution) / 10)
  r <- aggregate(r, fact = aggregate_inx, fun = mean)
  
  pal <- colorNumeric(pals, values(r),
                      na.color = "transparent")
  
  # set ploygon
  st_point <- st_point(c(lon, lat))%>% 
    st_sfc(crs = 4326) %>%  # WGS 1984
    st_transform(crs = 2436) # Beijing 1954 / Gauss-Kruger CM 117E
  st_circle <- st_buffer(st_point, dist = dist, nQuadSegs = 30) %>%
    st_transform(crs = 4326)
  
  # leaflet
  p <- leaflet() %>% addTiles() %>%
    addRasterImage(r, colors = pal, opacity = 0.8) %>%
    addPolygons(data = st_circle, color = "blue")%>%
    addLegend(pal = pal, values = values(r),
              title = "Value")
  
  return(p)
}