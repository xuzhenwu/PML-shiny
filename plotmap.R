
plotmap <- function(
  map,
  dir,
  varname,
  resolution,
  year,
  month,
  submonth,
  lat,
  lon,
  dist){
  
  
  #debug options
  # dir <- "F:/pml_data/"
  # varname = "landcover"
  # #varname = "GPP"
  # resolution =  60
  # year  = 2013
  # month = 6
  # submonth = "上半月"
  # lat = c(40.001501)
  # lon = c(116.379168)
  # dist = 500
  
  
  # modify for landcover
  if(varname != "landcover"){
    # compute layer
    layer <- 1
    if(str_detect(submonth, "上半月"))
      layer <- 2
    layer <- (as.numeric(month) - 1)*2 + layer
    fn <- dir(dir, 
              paste(varname, ".*", year, sep = "")
              , full.names = TRUE)
  }else{
    layer <- 1
    fn <- dir(dir, 
              paste(varname, sep = "")
              , full.names = TRUE)
  }
  # read raster file and aggreagate
  r <- raster(fn, band = layer)
  
  # pals
  palette <- c("Spectral", "YlGn", "Set1")
  pals <- palette[1]
  if(varname == "GPP"|
     varname == "LAI"){
    pals <- palette[2]
  }
  if(varname == "landcover")
    pals <- palette[3]
  pals <- brewer.pal(9, pals)
  
  # legend
  if(varname != "landcover"){
    pal <- colorNumeric(pals, values(r),
                        na.color = "transparent")
  }else{
    
    r <- ratify(r)
    rat <- levels(r)[[1]]
    rat$class <- c("Croplands", 
                   "Mixed Forest", 
                   "Grasslands", 
                   "Shrublands", 
                   "Wetland", 
                   "Water Bodies", 
                   "Impervious surface(Urban and Built-Up)", 
                   "Barren or Sparsely Vegetated")
    rat$class_chn <- c("农地", 
                   "混合林", 
                   "草地", 
                   "灌丛", 
                   "湿地", 
                   "水体", 
                   "不透水地表", 
                   "裸土")
    pals[6] <- c("#3708FF")
    
    levels(r) <- rat

    
    pal <- colorFactor(pals, values(r),
                       na.color = "transparent")
  }
  

  
  # leaflet
  if(varname != "landcover"){
    p <- map %>%
      addMarkers(lon, lat)%>%
      addRasterImage(r, colors = pal, opacity = 0.8,
                     maxBytes = Inf) %>%
      addLegend(pal = pal,
                position = "bottomleft",
                values = values(r),
                title = varname)
  }else{
    p <- map %>%
      addMarkers(lon, lat)%>%
      addRasterImage(r, colors = pal, opacity = 0.8,
                     maxBytes = Inf) %>%
      addLegend(pal = pal,
                position = "bottomleft",
                values = values(r),
                # not that category data needs transform
                labFormat = labelFormat(transform = function(x){
                  levels(r)[[1]]$class_chn[which(levels(r)[[1]]$ID == x)]
                }),
                title = varname)
  }
  p
  
  
  
  return(p)
}
