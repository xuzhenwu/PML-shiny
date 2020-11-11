
plotmap <- function(
  map,
  dir,
  varname,
  resolution,
  year,
  month,
  submonth){
  
  
  #debug options
  # dir <- "data/"
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
  
  aggregate_inx <- as.numeric(resolution) / 10
  if(aggregate_inx > 1){
    if(varname == "landcover")
      r <- aggregate(r, fact = aggregate_inx, fun = max) # may change as count 
    else 
      r <- aggregate(r, fact = aggregate_inx, fun = mean)
  }
  
  # pals
  palette <- c("Spectral", "YlGn", "Spectral")
  if(varname == "GPP"|
     varname == "LAI"){
    pals <- palette[2]
    pals <- brewer.pal(9, pals)
  }
  else{
    pals <- palette[1]
    pals <- brewer.pal(11, pals)
  }
  
  # legend
  if(varname != "landcover"){
    pal <- colorNumeric(pals, values(r),
                        na.color = "transparent")
  }else{
    
    r <- ratify(r)
    rat <- levels(r)[[1]]
    
    
    inx <- 1:9
    class <- c("Croplands", 
               "Mixed Forest", 
               "Grasslands", 
               "Shrublands", 
               "Wetland",
               "Water Bodies",
               "Tundra, Permanent Wetlands",
               "Impervious surface(Urban and Built-Up)", 
               "Barren or Sparsely Vegetated")
    class_chn <- c("农地", 
                   "混合林", 
                   "草地", 
                   "灌丛", 
                   "湿地", 
                   "水体",
                   "苔原",
                   "不透水地表", 
                   "裸土")
    pals <- c("#FAFE03", 
              "#31A278", 
              "#FFA800", 
              "#A84974", 
              "#008C94", 
              "#3708FF",
              "#CAFE8F",#IGBP 没有苔原？
              "#FF2A00", 
              "#AAAAAA")
    
    pals <- pals[rat$ID]
    
    print(rat$ID)
    rat$class <- class[rat$ID]
    rat$class_chn <- class_chn[rat$ID]
    
    
    
    levels(r) <- rat
    
    
    pal <- colorFactor(pals, values(r),
                       na.color = "transparent")
  }
  
  
  
  # legend.title
  title_label <- paste0(varname, " (", dt_varunit[variables == varname,]$units[1], ") ")
  
  # leaflet
  if(varname != "landcover"){
    p <- map %>%
      addRasterImage(r, colors = pal, opacity = 0.8,
                     maxBytes = Inf) %>%
      addLegend(pal = pal,
                position = "bottomleft",
                values = values(r),
                title = title_label)
  }else{
    p <- map %>%
      addRasterImage(r, colors = pal, opacity = 0.8,
                     maxBytes = Inf) %>%
      addLegend(pal = pal,
                position = "bottomleft",
                values = values(r),
                # not that category data needs transform
                labFormat = labelFormat(transform = function(x){
                  levels(r)[[1]]$class_chn[which(levels(r)[[1]]$ID == x)]
                }),
                title = title_label)
  }
  
  return(p)
}
